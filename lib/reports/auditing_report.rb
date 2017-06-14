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

      protocols = Protocol.find(@params[:protocols])

      if @params[:service_type] == "Per Patient Per Visit"
        csv << ["From", format_date(Time.strptime(@params[:start_date], "%m/%d/%Y")), "To", format_date(Time.strptime(@params[:end_date], "%m/%d/%Y"))]
        csv << [""]
        csv << [""]
        csv << [
          "Protocol ID",
          "Patient Name",
          "Patient ID",
          "Arm Name",
          "Visit Name",
          "Service Completion Date",
          "Marked as Incomplete Date",
          "Marked with Follow-Up Date",
          "Added?",
          "Nexus Core",
          "Service Name",
          "Completed?",
          "Billing Type (R/T/O)",
          "If not completed,
          reason and comment",
          "Follow-Up date and comment",
          "Cost"
        ]

        protocols.each do |protocol|
          protocol.procedures.to_a.select { |procedure| procedure.handled_date && (@start_date..@end_date).cover?(procedure.handled_date) }.each do |procedure|
            participant = procedure.appointment.participant

            csv << [
              protocol.srid,
              participant.full_name,
              participant.label,
              procedure.appointment.arm.name,
              procedure.appointment.name,
              format_date(procedure.completed_date.nil? ? nil : procedure.completed_date),
              format_date(procedure.incompleted_date.nil? ? nil : procedure.incompleted_date),
              format_date(procedure.follow_up? ? procedure.handled_date : nil),
              added_formatter(procedure),
              procedure.service.organization.name,
              procedure.service_name,
              complete_formatter(procedure),
              procedure.formatted_billing_type,
              reason_formatter(procedure),
              follow_up_formatter(procedure),
              display_cost(procedure.service_cost)
            ]
          end
        end
      elsif @params[:service_type] == "One Time Fees"
        csv << ["From", format_date(Time.strptime(@params[:start_date], "%m/%d/%Y")), "To", format_date(Time.strptime(@params[:end_date], "%m/%d/%Y"))]
        csv << [""]
        csv << [""]
        csv << [
          "Protocol ID",
          "Short Title",
          "Principal Investigator",
          "Organization",
          "Service Name",
          "Account",
          "Contact",
          "Quantity Type",
          "Unit Cost",
          "Requested",
          "Remaining",
          "Service Started Date",
          "Components",
          "Last Fulfillment Date",
          "Notes",
          "Documents",
          "Fields Modified",
          "Date"
        ]

        protocols.each do |protocol|
          protocol.line_items.each do |line_item|
            next unless line_item.versions.where(event: "update", created_at: @start_date..@end_date).any?
            line_item.versions.where(event: "update").each do |version|
              csv << [
                protocol.srid,
                protocol.short_title,
                protocol.pi.full_name,
                protocol.organization.abbreviation,
                line_item.service.name,
                line_item.account_number,
                line_item.contact_name,
                line_item.quantity_type,
                display_cost(line_item.cost),
                line_item.quantity_requested,
                line_item.quantity_remaining,
                format_date(line_item.started_at),
                line_item.components.where(selected: true).map(&:component).join(' | '),
                format_date(line_item.last_fulfillment),
                line_item.notes.map(&:comment).join(' | '),
                line_item.documents.map(&:title).join(' | '),
                changeset_formatter(version.changeset),
                format_date(version.created_at)
              ]
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
        formatted << "#{field.humanize}: #{Service.find(changes.first).name} => #{Service.find(changes.last).name}"
      else
        formatted << "#{field.humanize}: #{changes.first} => #{changes.last}"
      end
    end
    formatted.join(' | ')
  end
end
