# Copyright © 2011-2025 MUSC Foundation for Research Development~
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

class FinanceBillingReport < Report
  include ReportsSharedMethods

  VALIDATES_PRESENCE_OF = [:title, :start_date, :end_date].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  def generate(document)
    @start_date = Time.strptime(@params[:start_date], "%m/%d/%Y").utc
    @end_date   = Time.strptime(@params[:end_date], "%m/%d/%Y").tomorrow.utc - 1.second

    document.update(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    CSV.open(document.path, "wb") do |csv|
      csv << ["From", format_date(Time.strptime(@params[:start_date], "%m/%d/%Y")), "To", format_date(Time.strptime(@params[:end_date], "%m/%d/%Y"))]
      csv << [""]

      headers = [
        "RMID",                       # 1
        "Protocol ID",                # 2
        "Request ID",                 # 3
        "Status",                     # 4
        "Short Title",                # 5
        "Proposal Funding Status",    # 6
        "Funding Start Date",         # 7
        "Funding Source",             # 8
        "Previous Funding Source",    # 9
        "Funding Source Change Date", # 10
        "Primary PI",                 # 11
        "Primary PI Affiliation",     # 12
        "Billing/Business Manager(s)",# 13
        "Core/Program",               # 14
        "Service Type",               # 15
        "Service",                    # 16
        "Performed By",               # 17
        "Components",                 # 18
        "Contact",                    # 19
        "Account #",                  # 20
        "Patient Name",               # 21
        "Patient ID",                 # 22
        "Visit Name",                 # 23
        "Visit Date",                 # 24
        "Notes",                      # 25
        "Fulfilled/Completion Date",  # 26
        "Fiscal Year",                # 28
        "Quantity Completed",         # 29
        "Quantity Type",              # 30
        "Research Rate",              # 31
        "Total Cost",                 # 32
        "Modified Rate",              # 33
        "Percent Subsidy",            # 34
        "Invoiced",                   # 35
        "Invoiced Date"               # 36
      ]

      csv << headers

      protocols = Protocol.includes(
        :pi,
        { sparc_protocol: [:audits] },
        :project_roles,
        :sub_service_request,
        :subsidy,
        fulfillments: [
          :components,
          :performer,
          { line_item: [:admin_rates], service: [:organization] }
        ],
        procedures: [
          :visit,
          { service: [:organization, :pricing_maps], appointment: [:visit_group] }
        ]
      ).where(id: @params[:protocols])

      protocols.each do |protocol|
        funding_info = get_previous_funding_source(protocol)
        previous_funding_source = funding_info[:previous_funding_source]
        funding_source_change_date = funding_info[:change_date]

        fulfillments = protocol.fulfillments.select{ |fulfillment| fulfillment.fulfilled_at >= @start_date && fulfillment.fulfilled_at <= @end_date}

        procedures = protocol.procedures.select { |procedure| procedure.completed_date != nil && procedure.completed_date >= @start_date && procedure.completed_date <= @end_date && procedure.billing_type == 'research_billing_qty' }

        fulfillments.each do |fulfillment|
          fulfillment_completed_date = fulfillment.fulfilled_at

          next if fulfillment.credited?

          data = []
          data << protocol.research_master_id # 1
          data << format_protocol_id_column(protocol) # 2
          data << protocol.sub_service_request.ssr_id # 3
          data << formatted_status(protocol) # 4
          data << protocol.sparc_protocol.short_title # 5
          data << protocol.sparc_protocol&.funding_status&.humanize # 6
          data << protocol.sparc_protocol&.funding_start_date&.strftime("%m/%d/%Y") # 7 - Funding Start Date
          data << protocol.sparc_protocol.funding_source.humanize # 8 - Funding Source
          data << previous_funding_source # 9
          data << funding_source_change_date # 10
          data << protocol.pi&.full_name # 11
          data << (protocol.pi ? [protocol.pi.professional_org_lookup("institution"), protocol.pi.professional_org_lookup("college"), protocol.pi.professional_org_lookup("department"), protocol.pi.professional_org_lookup("division")].compact.join("/") : nil) # 12
          data << protocol.billing_business_managers.map(&:full_name).join(',') # 13
          data << fulfillment.service.organization.name # 14
          data << "Non-Clinical Service" # 15
          data << fulfillment.service_name # 16
          data << fulfillment.performer.full_name # 17
          data << fulfillment.components.map(&:component).join(',') # 18
          data << fulfillment.line_item.contact_name # 19
          data << fulfillment.line_item.account_number # 20
          data << nil # 21 patient name
          data << nil # 22 patient id
          data << nil # 23 visit name
          data << nil # 24 visit date
          data << fulfillment.notes.map(&:comment).join(' | ') # 25
          data << fulfillment_completed_date.strftime("%m/%d/%Y") # 26
          data << fiscal_year_display(fulfillment_completed_date) # 28 fiscal year
          data << fulfillment.quantity # 29
          data << fulfillment.line_item.quantity_type # 30
          data << display_cost(fulfillment.service_cost) # 31
          data << display_cost(fulfillment.total_cost) # 32
          data << display_otf_modified_rate_column(fulfillment) # 33
          data << display_subsidy_percent(fulfillment) # 34
          data << (fulfillment.invoiced? ? "Yes" : "No") # 35
          data << format_date(fulfillment.invoiced_date) # 36
          csv << data
        end

        procedures.group_by{|procedure| procedure.service.organization}.each do |org, org_group|

          org_group.group_by{|procedure| procedure.appointment.visit_group}.each do |visit_group, vg_group|

            vg_group.group_by(&:appointment).each do |appointment, appointment_group|
              protocols_participant = appointment.protocols_participant
              participant = protocols_participant.participant

              appointment_group.group_by(&:service_name).each do |service_name, service_group|
                procedure = service_group.first
                unless procedure.credited?
                  procedure_completed_date = procedure.completed_date

                  data = []
                  data << protocol.research_master_id # 1 rmid
                  data << format_protocol_id_column(protocol) # 2 protocol id
                  data << protocol.sub_service_request.ssr_id # 3 ssr id
                  data << formatted_status(protocol) # 4 status
                  data << protocol.sparc_protocol.short_title # 5 short title
                  data << protocol.sparc_protocol&.funding_status&.humanize # 6 funding status
                  data << protocol.sparc_protocol&.funding_start_date&.strftime("%m/%d/%Y") # 7 - Funding Start Date
                  data << protocol.sparc_protocol.funding_source.humanize
                  data << previous_funding_source # 9 - Previous Funding Source
                  data << funding_source_change_date # 10 - Funding Source Change Date
                  data << protocol.pi&.full_name # 11 primary pi
                  data << (protocol.pi ? [protocol.pi.professional_org_lookup("institution"), protocol.pi.professional_org_lookup("college"), protocol.pi.professional_org_lookup("department"), protocol.pi.professional_org_lookup("division")].compact.join("/") : nil) # 12 primary pi affiliation
                  data << protocol.billing_business_managers.map(&:full_name).join(',') # 13 billing/business manager(s)
                  data << procedure.service.organization.name # 14 core/program
                  data << "Clinical Service" # 15 service type
                  data << procedure.service_name # 16 service
                  data << nil # 17 performed by
                  data << nil # 18 components
                  data << nil # 19 contact
                  data << nil # 20 account number
                  data << participant.full_name # 21 patient name
                  data << (participant.label || protocols_participant.label) # 22 patient id
                  data << (appointment.name || procedure.appointment.name) # 23 visit name
                  data << (format_date(appointment.start_date) || format_date(procedure.appointment.start_date)) # 24 visit date
                  data << procedure.notes.map(&:comment).join(' | ') # 25 notes
                  data << format_date(procedure_completed_date) # 26 completed date
                  data << fiscal_year_display(procedure_completed_date) # 28 fiscal year
                  data << service_group.size # 29 quantity completed
                  data << procedure.service.current_effective_pricing_map.unit_type # 30 clinical quantity type
                  data << display_cost(procedure.service_cost) # 31 research rate
                  data << display_cost(service_group.size * procedure.service_cost.to_f) # 32 total cost
                  data << display_pppv_modified_rate_column(procedure) # 33 modified rate
                  data << (procedure.percent_subsidy ? display_subsidy_percent(procedure) : nil) # 34 percent subsidy
                  data << (procedure.invoiced? ? "Yes" : "No") # 35
                  data << (procedure.invoiced_date ? format_date(procedure.invoiced_date) : nil)# 36

                  csv << data
                end
              end
            end
          end
        end
      end
    end
  end
end
