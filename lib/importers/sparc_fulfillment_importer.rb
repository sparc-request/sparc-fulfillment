class SparcFulfillmentImporter
  # Tables to import
  # protocol
  # subjects
  # appointments
  # calendars
  # charges?
  # admin_rates?
  # fulfillments
  # notes
  # procedures
  # reports
  
  RACE_OPTIONS = {'native_american/alaskan' => 'American Indian/Alaska Native', 
                  'asian' => 'Asian', 
                  'pacific_islander' => 'Native Hawaiian or other Pacific Islander', 
                  'black' => 'Black or African American', 
                  'caucasian' => 'White', 
                  'middle_eastern' => 'Middle Eastern',
                  'other' => 'Unknown/Other/Unreported'}.freeze


  #TODO need to map statuses as well, just waiting on Lane to send a mapping

  def initialize(callback_url)
    @callback_url = callback_url
  end

  def create
    ActiveRecord::Base.transaction do
      fulfillment_protocol = ProtocolImporter.new(@callback_url).create

      disable_paper_trail

      sparc_protocol = Sparc::Protocol.find fulfillment_protocol.sparc_id
      
      # loop over arms to create participants and procedures
      sparc_protocol.arms.each do |sparc_arm|
        fulfillment_arm = Arm.where(sparc_id: sparc_arm.id, protocol_id: fulfillment_protocol.id).first

        sparc_arm.subjects.each do |sparc_subject|

          if sparc_subject.gender == 'other'
            puts "SPARC subject gender invalid: #{sparc_subject.inspect}"
            raise ActiveRecord::Rollback 
          end

          fulfillment_participant = nil

          if name_parts = NameParser.new(sparc_subject.name).parse # add this subject if we have name attributes

            fulfillment_participant = fulfillment_protocol.participants.new(first_name:      name_parts[:first_name],
                                                                            last_name:      name_parts[:last_name],
                                                                            middle_initial: name_parts[:middle_initial],
                                                                            address:        'N/A',
                                                                            city:           'N/A',
                                                                            state:          'N/A',
                                                                            zipcode:        '12345',
                                                                            phone:          '555-555-5555',
                                                                            mrn:            sparc_subject.mrn,
                                                                            external_id:    sparc_subject.external_subject_id,
                                                                            status:         sparc_subject.status,
                                                                            date_of_birth:  sparc_subject.dob.strftime("%m-%d-%Y"),
                                                                            gender:         sparc_subject.gender.capitalize,
                                                                            ethnicity:      'Unknown/Other/Unreported', 
                                                                            race:           RACE_OPTIONS[sparc_subject.ethnicity],
                                                                            arm:            fulfillment_arm)
            if fulfillment_participant.valid?
              fulfillment_participant.save
            else
              puts "Invalid participant #{fulfillment_participant.errors.inspect}"
              raise ActiveRecord::Rollback 
            end
          end # end adding participant

          # grab the subjects calendar and start looping over appointments

          sparc_calendar = sparc_subject.calendar

          sparc_calendar.appointments.each do |sparc_appointment|
            fulfillment_visit_group = VisitGroup.where(sparc_id: sparc_appointment.visit_group_id, arm_id: fulfillment_arm.id).first

            fulfillment_appointment = fulfillment_participant.appointments.create(visit_group_id:        fulfillment_visit_group.id,
                                                                                  visit_group_position:  fulfillment_visit_group.position,
                                                                                  position:              fulfillment_visit_group.position,
                                                                                  name:                  fulfillment_visit_group.name,
                                                                                  arm_id:                fulfillment_arm.id,
                                                                                  start_date:            (sparc_appointment.completed_at.strftime("%m-%d-%Y") rescue nil),
                                                                                  end_date:              (sparc_appointment.completed_at.strftime("%m-%d-%Y") rescue nil))

                                                                                  

          end

          



        end # end looping over subjects
      end # end looping over arms
    end # end transaction block

    enable_paper_trail
  end

  private

  def enable_paper_trail
    PaperTrail.enabled = false
  end
  
  def disable_paper_trail
    PaperTrail.enabled = false
  end
end
