# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

class AuditingReport < Report
  VALIDATES_PRESENCE_OF = [:service_type, :title, :start_date, :end_date, :protocols].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  def generate(document)
    #We want to filter from 00:00:00 in the local time zone,
    #then convert to UTC to match database times
    @start_date = Time.strptime(@params[:start_date], "%m/%d/%Y").utc
    #We want to filter from 11:59:59 in the local time zone,
    #then convert to UTC to match database times
    @end_date   = Time.strptime(@params[:end_date], "%m/%d/%Y").tomorrow.utc - 1.second

    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    CSV.open(document.path, "wb") do |csv|

      protocols = Protocol.where(id: @params[:protocols]).includes(:pi, :organization, procedures: [:arm, :notes, :task, service: [:organization], appointment: [protocols_participant: [:participant]]], line_items: [:service, :components, :notes, :documents])

      if @params[:service_type] == "Clinical Services"
        csv << ["From", format_date(Time.strptime(@params[:start_date], "%m/%d/%Y")), "To", format_date(Time.strptime(@params[:end_date], "%m/%d/%Y"))]
        csv << [""]
        csv << [""]

        header = [ "Protocol ID" ]
        header << "RMID" if ENV.fetch('RMID_URL'){nil}
        header << "Patient Name"
        header << "Patient ID"
        header << "Arm Name"
        header << "Visit Name"
        header << "Service Completion Date"
        header << "Marked as Incomplete Date"
        header << "Marked with Follow-Up Date"
        header << "Added?"
        header << "Nexus Core"
        header << "Service Name"
        header << "Completed?"
        header << "Billing Type (R/T/O)"
        header << "If not completed, reason and comment"
        header << "Follow-Up date and comment"
        header << "Cost"
        header << "Notes"

        csv << header

        protocols.each do |protocol|
          protocol.procedures.to_a.select { |procedure| procedure.handled_date && (@start_date..@end_date).cover?(procedure.handled_date) }.each do |procedure|
            appointment = procedure.appointment
            protocols_participant = appointment.protocols_participant
            participant = protocols_participant.participant

            data = [ protocol.srid ]
            data << protocol.research_master_id if ENV.fetch('RMID_URL'){nil}
            data << participant.full_name
            data << protocols_participant.label
            data << appointment.arm.name
            data << appointment.name
            data << format_date(procedure.completed_date.nil? ? nil : procedure.completed_date)
            data << format_date(procedure.incompleted_date.nil? ? nil : procedure.incompleted_date)
            data << format_date(procedure.follow_up? ? procedure.handled_date : nil)
            data << added_formatter(procedure)
            data << procedure.sparc_core_name
            data << procedure.service_name
            data << complete_formatter(procedure)
            data << procedure.formatted_billing_type
            data << reason_formatter(procedure)
            data << follow_up_formatter(procedure)
            data << display_cost(procedure.service_cost)
            data << procedure.notes.map(&:comment).join(' | ')

            csv << data
          end
        end
      else
        csv << ["From", format_date(Time.strptime(@params[:start_date], "%m/%d/%Y")), "To", format_date(Time.strptime(@params[:end_date], "%m/%d/%Y"))]
        csv << [""]
        csv << [""]

        header = [ "Protocol ID" ]
        header << "RMID" if ENV.fetch('RMID_URL'){nil}
        header << "Short Title"
        header << "Principal Investigator"
        header << "Organization"
        header << "Service Name"
        header << "Account"
        header << "Contact"
        header << "Quantity Type"
        header << "Unit Cost"
        header << "Requested"
        header << "Remaining"
        header << "Service Started Date"
        header << "Components"
        header << "Last Fulfillment Date"
        header << "Notes"
        header << "Documents"
        header << "Fields Modified"
        header << "Date"

        csv << header

        protocols.each do |protocol|
          protocol.line_items.each do |line_item|
            next unless line_item.versions.where(event: ["create", "update"], created_at: @start_date..@end_date).any? && line_item.service.one_time_fee?
            line_item.versions.where(event: ["create", "update"]).each do |version|
              data = [ protocol.srid ]
              data << protocol.research_master_id if ENV.fetch('RMID_URL'){nil}
              data << protocol.short_title
              data << protocol.pi.full_name
              data << protocol.organization.abbreviation
              data << line_item.service.name
              data << line_item.account_number
              data << line_item.contact_name
              data << line_item.quantity_type
              data << display_cost(line_item.cost)
              data << line_item.quantity_requested
              data << line_item.quantity_remaining
              data << format_date(line_item.started_at)
              data << line_item.components.where(selected: true).map(&:component).join(' | ')
              data << format_date(line_item.last_fulfillment)
              data << line_item.notes.map(&:comment).join(' | ')
              data << line_item.documents.map(&:title).join(' | ')
              data << changeset_formatter(version.changeset)
              data << format_date(version.created_at)

              csv << data
            end
          end
        end
      end
    end
  end

  private

  def added_formatter(procedure)
    procedure.visit ? "" : "**Added**"
  end

  def complete_formatter(procedure)
    procedure.complete? ? "Yes" : "No"
  end

  def reason_formatter(procedure)
    if procedure.incomplete? && procedure.reason_note
      procedure.reason_note.comment
    end
  end

  def follow_up_formatter(procedure)
    if procedure.follow_up_date
      "Due Date: #{format_date(procedure.follow_up_date)} | Comment: #{procedure.task.body}"
    end
  end

  def changeset_formatter(changeset)
    formatted = []
    changeset.select{|k, v| k != "updated_at"}.each do |field, changes|
      if field == "service_id"
        original_service = Service.find_by_id(changes.first)
        new_service = Service.find_by_id(changes.last)
        formatted << "#{field.humanize}: #{original_service.nil? ? 'Service Not Found' : original_service.name} => #{new_service.nil? ? 'Service Not Found' : new_service.name}}"
      else
        formatted << "#{field.humanize}: #{changes.first} => #{changes.last}"
      end
    end
    formatted.join(' | ')
  end
end
