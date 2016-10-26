# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class SparcFulfillmentImporter
  RACE_OPTIONS = {'native_american/alaskan' => 'American Indian/Alaska Native',
                  'asian' => 'Asian',
                  'pacific_islander' => 'Native Hawaiian or other Pacific Islander',
                  'black' => 'Black or African American',
                  'caucasian' => 'White',
                  'middle_eastern' => 'Middle Eastern',
                  'other' => 'Unknown/Other/Unreported'}.freeze

  STATUS_OPTIONS = {'Active' => 'Enrolled - Receiving Treatment',
                    'Completed' => 'Completed',
                    'Early Term' => 'Completed',
                    'Screen Fail' => 'Completed'}.freeze


  def self.import_all(ignored=[])
    skipped = {}
    processed = []

    Sparc::SubServiceRequest.where(in_work_fulfillment: true, status: 'ctrc_approved').each do |ssr|
      next if ignored.include?(ssr.id)
      begin
        base_url = "#{ENV.fetch('GLOBAL_SCHEME')}://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}"
        SparcFulfillmentImporter.new("#{base_url}/sub_service_requests/#{ssr.id}.json").create
        processed << ssr.id
        puts "*"*50
        puts "Imported #{ssr.id}"
        puts "*"*50
      rescue Exception => e
        puts "*"*50
        puts "Failed #{ssr.id}"
        puts e.message
        puts "*"*50
        skipped[ssr.id] = e.message
      end
    end

    puts "*"*100
    puts "*"*100
    puts "Ignored SSR ids = #{ignored.inspect}"
    puts "Skipped SSR ids = #{skipped.inspect}"
    puts "Processed SSR ids = #{processed.inspect}"
    puts "*"*100
    puts "*"*100
  end

  def initialize(callback_url)
    @callback_url = callback_url
    @fulfillment_protocol = nil
  end

  def create
    ActiveRecord::Base.transaction do
      Time.use_zone 'Eastern Time (US & Canada)' do
        @fulfillment_protocol = ProtocolImporter.new(@callback_url).create

        disable_paper_trail

        sparc_protocol = Sparc::Protocol.find @fulfillment_protocol.sparc_id

        # create SLA fulfillments
        @fulfillment_protocol.one_time_fee_line_items.each do |fulfillment_line_item|
          sparc_line_item = Sparc::LineItem.find(fulfillment_line_item.sparc_id)

          sparc_line_item.fulfillments.each do |sparc_line_item_fulfillment|
            create_line_item_fulfillment(sparc_line_item_fulfillment, fulfillment_line_item)
          end
        end

        # create documents
        sparc_sub_service_request = Sparc::SubServiceRequest.find(@fulfillment_protocol.sub_service_request_id)

        sparc_sub_service_request.reports.each do |report|
          create_fulfillment_document(report)
        end

        # loop over arms to create participants and procedures
        sparc_protocol.arms.each do |sparc_arm|
          fulfillment_arm = Arm.where(sparc_id: sparc_arm.id, protocol_id: @fulfillment_protocol.id).first

          sparc_arm.subjects.each do |sparc_subject|
            next if sparc_subject.name.present? && sparc_subject.name.match(/do not/i)

            fulfillment_participant = nil

            if name_parts = NameParser.new(sparc_subject.name).parse # add this subject if we have name attributes
              fulfillment_participant = create_fulfillment_participant(name_parts, sparc_subject, fulfillment_arm)

              # grab the subjects calendar and start looping over appointments
              sparc_calendar = sparc_subject.calendar

              sparc_calendar.appointments.each do |sparc_appointment|
                fulfillment_visit_group = VisitGroup.where(sparc_id: sparc_appointment.visit_group_id, arm_id: fulfillment_arm.id).first
                next unless fulfillment_visit_group.present?
                fulfillment_appointment = nil

                unless fulfillment_appointment = Appointment.where(participant_id: fulfillment_participant.id, visit_group_id: fulfillment_visit_group.id, arm_id: fulfillment_arm.id).first
                  fulfillment_appointment = create_fulfillment_appointment(fulfillment_participant, fulfillment_visit_group, fulfillment_arm, sparc_appointment)
                end

                create_fulfillment_notes(sparc_appointment, fulfillment_appointment)
                create_fulfillment_procedures(sparc_appointment, fulfillment_appointment)
              end
            end # end adding participant, appointments, and procedures
          end # end looping over subjects
        end # end looping over arms
      end # end Time.use_zone block

      #enable_paper_trail
    end # end transaction block

  end

  private

  def enable_paper_trail
    PaperTrail.enabled = true
  end

  def disable_paper_trail
    PaperTrail.enabled = false
  end

  def create_line_item_fulfillment(sparc_line_item_fulfillment, fulfillment_line_item)
    sparc_line_item_fulfillment_audit = sparc_line_item_fulfillment.audits.where(action: 'create').first
    sparc_unit_quantity = sparc_line_item_fulfillment.unit_quantity || 1
    sparc_quantity = sparc_line_item_fulfillment.quantity || 0
    quantity = sparc_quantity * sparc_unit_quantity

    fulfillment_line_item_fulfillment = fulfillment_line_item.fulfillments.new(sparc_id: sparc_line_item_fulfillment.id,
                                                                               fulfilled_at: sparc_line_item_fulfillment.date.strftime("%m/%d/%Y"),
                                                                               quantity:     quantity,
                                                                               performer_id: sparc_line_item_fulfillment_audit.user_id,
                                                                               service_id:   fulfillment_line_item.service_id,
                                                                               service_name: fulfillment_line_item.service.name)

    if sparc_line_item_fulfillment.notes
      fulfillment_line_item_fulfillment.notes.new(comment: sparc_line_item_fulfillment.notes,
                                                  identity_id: sparc_line_item_fulfillment_audit.user_id)
    end

    validate_and_save fulfillment_line_item_fulfillment
  end

  def create_fulfillment_document(sparc_report)
    document = @fulfillment_protocol.documents.create(original_filename: sparc_report.xlsx_file_name,
                                                      content_type:      sparc_report.xlsx_content_type,
                                                      title:             'Project Summary Report',
                                                      state:             'Completed')

    File.open(document.path, 'wb') do |file|
      file.write(sparc_report.fetch)
    end

    validate_and_save document
  end

  def create_fulfillment_participant(name_parts, sparc_subject, fulfillment_arm)
    fulfillment_participant = @fulfillment_protocol.participants.new(sparc_id:       sparc_subject.id,
                                                                     first_name:     name_parts[:first_name],
                                                                     last_name:      name_parts[:last_name],
                                                                     middle_initial: name_parts[:middle_initial],
                                                                     address:        'N/A',
                                                                     city:           'N/A',
                                                                     state:          'N/A',
                                                                     zipcode:        '12345',
                                                                     phone:          '555-555-5555',
                                                                     mrn:            sparc_subject.mrn,
                                                                     external_id:    sparc_subject.external_subject_id,
                                                                     status:         STATUS_OPTIONS[sparc_subject.status],
                                                                     date_of_birth:  (sparc_subject.dob.present? ? sparc_subject.dob.strftime("%m/%d/%Y") : nil),
                                                                     gender:         sparc_subject.gender.capitalize,
                                                                     ethnicity:      'Unknown/Other/Unreported',
                                                                     race:           RACE_OPTIONS[sparc_subject.ethnicity],
                                                                     arm:            fulfillment_arm)

    validate_and_save fulfillment_participant
  end

  def create_fulfillment_appointment(fulfillment_participant, fulfillment_visit_group, fulfillment_arm, sparc_appointment)
    fulfillment_appointment = fulfillment_participant.appointments.new(sparc_id:              sparc_appointment.id,
                                                                       visit_group_id:        fulfillment_visit_group.id,
                                                                       visit_group_position:  fulfillment_visit_group.position,
                                                                       position:              fulfillment_visit_group.position,
                                                                       name:                  fulfillment_visit_group.name,
                                                                       arm_id:                fulfillment_arm.id,
                                                                       start_date:            sparc_appointment.completed_at,
                                                                       completed_date:        sparc_appointment.completed_at)

    validate_and_save fulfillment_appointment
  end

  def create_fulfillment_notes(sparc_appointment, fulfillment_appointment)
    sparc_appointment.notes.each do |sparc_note|
      fulfillment_note = fulfillment_appointment.notes.new(identity_id: sparc_note.identity_id,
                                                           comment:     sparc_note.body,
                                                           created_at:  sparc_note.created_at)

      validate_and_save fulfillment_note
    end
  end

  def create_fulfillment_procedures(sparc_appointment, fulfillment_appointment)
    sparc_appointment.procedures.each do |sparc_procedure|

      r_quantity = sparc_procedure.r_quantity || (sparc_procedure.visit.present? ? sparc_procedure.visit.research_billing_qty : nil) || 1
      t_quantity = sparc_procedure.t_quantity || (sparc_procedure.visit.present? ? sparc_procedure.visit.insurance_billing_qty : nil) || 0

      generate_procedures(sparc_procedure, fulfillment_appointment, r_quantity, 'research_billing_qty')
      generate_procedures(sparc_procedure, fulfillment_appointment, t_quantity, 'insurance_billing_qty')
    end
  end

  def displayed_in_sparc sparc_procedure
    if sparc_procedure.service
      return true
    elsif sparc_procedure.visit
      if sparc_procedure.completed
        return true
      elsif sparc_procedure.line_item.service.one_time_fee
        return false
      elsif sparc_procedure.appointment.visit_group_id.nil?
        return true if sparc_procedure.completed
      else
        if (sparc_procedure.visit.research_billing_qty && sparc_procedure.visit.research_billing_qty > 0) or (sparc_procedure.visit.insurance_billing_qty && sparc_procedure.visit.insurance_billing_qty > 0)
          return true
        else
          return false
        end
      end
    elsif sparc_procedure.appointment.visit_group_id.nil?
      return true if sparc_procedure.completed
    end

    return false
  end

  def generate_procedures(sparc_procedure, fulfillment_appointment, quantity, billing_type)
    return if quantity == 0
    return unless displayed_in_sparc(sparc_procedure)

    sparc_line_item_id = sparc_procedure.line_item_id
    sparc_service_id = sparc_procedure.service_id
    line_item = LineItem.where(sparc_id: sparc_line_item_id, protocol_id: @fulfillment_protocol.id).first

    if sparc_line_item_id.present? && line_item.present? # this is a needed check for bad data
      fulfillment_service = line_item.service
    else
      fulfillment_service = Service.where(id: sparc_service_id).first
    end

    fulfillment_visit_id = nil
    if sparc_line_item_id.present?
      fulfillment_line_item = LineItem.where(sparc_id: sparc_line_item_id, protocol_id: @fulfillment_protocol.id).first
      if fulfillment_line_item.present?
        visit = Visit.where(sparc_id: sparc_procedure.visit_id, line_item_id: fulfillment_line_item.id).first
      end
      fulfillment_visit_id = visit.present? ? visit.id : nil # we forgot about the case where a sparc procedure doesn't have a visit id
    end

    sparc_organization = sparc_procedure.appointment.organization
    quantity.times do
      if fulfillment_service.present? # this is a needed check for bad data.
        fulfillment_procedure = fulfillment_appointment.procedures.new(sparc_id:       sparc_procedure.id,
                                                                      service_id:      fulfillment_service.id,
                                                                      appointment_id:  fulfillment_appointment.id,
                                                                      service_name:    fulfillment_service.name,
                                                                      billing_type:    billing_type,
                                                                      sparc_core_id:   sparc_organization.id,
                                                                      sparc_core_name: sparc_organization.name,
                                                                      visit_id:        fulfillment_visit_id)

        if sparc_procedure.completed? and sparc_procedure.appointment.completed_at.present?
          sparc_procedure_completed_audit = sparc_procedure.audits.where("audited_changes like '%completed: true%' OR audited_changes like '%completed:\n- false\n- true%'").first
          sparc_procedure_completed_date = sparc_procedure.appointment.completed_at
          sparc_procedure_completed_by = sparc_procedure_completed_audit.user_id

          fulfillment_procedure.status = 'complete'
          fulfillment_procedure.completed_date = sparc_procedure_completed_date.strftime("%m/%d/%Y")
          fulfillment_procedure.service_cost = fulfillment_service.cost(fulfillment_procedure.protocol.sparc_funding_source, sparc_procedure_completed_date)
          fulfillment_procedure.performer_id = sparc_procedure_completed_by
        end

        validate_and_save fulfillment_procedure
      end
    end
  end

  def validate_and_save object
    #### don't validate subjects, unfortunately they didn't have validation in SPARC
    if object.class.to_s == 'Participant'
      object.save(validate: false)
    elsif object.valid?
      object.save
    else
      puts "#"*50
      puts "Invalid object #{object.errors.inspect}"
      puts "#"*50
      raise ActiveRecord::Rollback
    end

    object
  end
end
