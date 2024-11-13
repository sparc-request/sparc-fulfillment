class FinanceBillingReport < Report

  # VALIDATES_PRESENCE_OF = [:title, :start_date, :end_date, :sort_by, :sort_order, :organizations, :protocols].freeze
  # VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  def format_protocol_id_column(protocol)
    protocol.subsidies.any? ? protocol.sparc_id.to_s + 's' : protocol.sparc_id
  end

  def display_pppv_modified_rate_column(procedure)
    admin_rate = procedure.send(:admin_rate)
    admin_rate && admin_rate.created_at.to_date <= procedure.completed_date.to_date || procedure.send(:old_admin_rates) && procedure.send(:check_old_admin_rates, procedure.completed_date) ? "Yes" : "No"
  end

  def display_otf_modified_rate_column(fulfillment)
    line_item = fulfillment.line_item
    line_item.send(:current_admin_rate) && line_item.send(:current_admin_rate_applicable?, fulfillment.fulfilled_at) || line_item.send(:old_admin_rates) && line_item.send(:applicable_old_admin_rate, fulfillment.fulfilled_at) ? "Yes" : "No"
  end

  def display_subsidy_percent(object)
    object.percent_subsidy.nil? ? "N/A" : "#{object.percent_subsidy * 100}%"
  end

  def insert_blank_column_for_notes(totals, include_notes)
    totals.insert(0, "") if include_notes
    totals
  end

  def generate(file_path, params)
    @start_date = Time.strptime(params[:start_date], "%m/%d/%Y").utc
    @end_date   = Time.strptime(params[:end_date], "%m/%d/%Y").tomorrow.utc - 1.second
    @specific_services = params[:services].present? ? params[:services].map(&:to_i) : []

    # document.update_attributes(content_type: 'text/csv', original_filename: "#{params[:title]}.csv")

    CSV.open(file_path, "wb") do |csv|
      csv << ["From", format_date(Time.strptime(params[:start_date], "%m/%d/%Y")), "To", format_date(Time.strptime(params[:end_date], "%m/%d/%Y"))]
      csv << [""]

      headers = [
        "Protocol ID",                # 1
        "Request ID",                 # 2
        "RMID",                       # 3
        "Short Title",                # 4
        "Funding Source",             # 5
        "Status",                     # 6
        "Primary PI",                 # 7
        "Primary PI Affiliation",     # 8
        "Billing/Business Manager(s)",# 9
        "Core/Program",               # 10
        "Service",                    # 11
        "Service Completion Date",    # 12
        "Fulfillment Date",           # 13
        "Performed By",               # 14
        "Components",                 # 15
        "Contact",                    # 16
        "Account #",                  # 17
        "Patient Name",               # 18
        "Patient ID",                 # 19
        "Visit Name",                 # 20
        "Visit Date",                 # 21
        "Notes",                      # 22
        "Quantity Completed",         # 23
        "Quantity Type",              # 24
        "Clinical Quantity Type",     # 25
        "Research Rate",              # 26
        "Total Cost",                 # 27
        "Modified Rate",              # 28
        "Percent Subsidy",            # 29
        "Invoiced",                   # 30
        "Invoiced Date"               # 31
      ]

      csv << headers

      protocols = Protocol.includes(
        :pi, :sparc_protocol, :project_roles, :sub_service_request, :subsidy,
        fulfillments: [:components, :performer, line_item: [:admin_rates], service: [:organization]],
        procedures: [:visit, service: [:organization, :pricing_maps], appointment: [:visit_group]]
      ).where(id: params[:protocols])

      protocols.each do |protocol|
        fulfillments = protocol.fulfillments.select{ |fulfillment| fulfillment.fulfilled_at >= @start_date && fulfillment.fulfilled_at <= @end_date && (@specific_services.present? ? @specific_services.include?(fulfillment.service_id) : true)}

        procedures = protocol.procedures.select{|procedure| procedure.completed_date != nil && procedure.completed_date >= @start_date && procedure.completed_date <= @end_date && procedure.billing_type == 'research_billing_qty' && (@specific_services.present? ? @specific_services.include?(procedure.service_id) : true)}

        fulfillments.each do |fulfillment|
          next if fulfillment.credited?

          data = []
          data << format_protocol_id_column(protocol) # 1
          data << protocol.sub_service_request.ssr_id # 2
          data << protocol.research_master_id # 3
          data << protocol.sparc_protocol.short_title # 4
          data << fulfillment.funding_source # 5
          data << formatted_status(protocol) # 6
          data << protocol.pi&.full_name # 7
          data << (protocol.pi ? [protocol.pi.professional_org_lookup("institution"), protocol.pi.professional_org_lookup("college"),
            protocol.pi.professional_org_lookup("department"), protocol.pi.professional_org_lookup("division")].compact.join("/") : nil) # 8
          data << protocol.billing_business_managers.map(&:full_name).join(',') # 9
          data << fulfillment.service.organization.name # 10
          data << fulfillment.service_name # 11
          data << nil # 12 - Service Completion Date
          data << format_date(fulfillment.fulfilled_at) # 13
          data << fulfillment.performer.full_name # 14
          data << fulfillment.components.map(&:component).join(',') # 15
          data << fulfillment.line_item.contact_name # 16
          data << fulfillment.line_item.account_number # 17
          data << nil # 18 patient name
          data << nil # 19 patient id
          data << nil # 20 visit name
          data << nil # 21 visit date
          data << fulfillment.notes.map(&:comment).join(' | ') # 22
          data << fulfillment.quantity # 23
          data << fulfillment.line_item.quantity_type # 24
          data << nil # 25 clinical quantity type
          data << display_cost(fulfillment.service_cost) # 26 research rate
          data << display_cost(fulfillment.total_cost) # 27 total cost
          data << display_otf_modified_rate_column(fulfillment) # 28 modified rate
          data << display_subsidy_percent(fulfillment) # 29 percent subsidy
          data << (fulfillment.invoiced? ? "Yes" : "No") # 30
          data << format_date(fulfillment.invoiced_date) # 31

          csv << data
        end

        procedures.group_by{|procedure| procedure.service.organization}.each do |org, org_group|

          org_group.group_by{|procedure| procedure.appointment.visit_group}.each do |visit_group, vg_group|

            vg_group.group_by(&:appointment).each do |appointment, appointment_group|
              protocols_participant = appointment.protocols_participant
              participant = protocols_participant.participant

              appointment_group.group_by(&:service_name).each do |service_name, service_group|
                procedure = service_group.first
                if !procedure.credited?

                  data = []
                  data << format_protocol_id_column(protocol) # 1
                  data << protocol.sub_service_request.ssr_id # 2
                  data << protocol.research_master_id # 3
                  data << protocol.sparc_protocol.short_title # 4
                  data << procedure.funding_source # 5
                  data << formatted_status(protocol) # 6
                  data << protocol.pi&.full_name # 7
                  data << (protocol.pi ? [protocol.pi.professional_org_lookup("institution"), protocol.pi.professional_org_lookup("college"), protocol.pi.professional_org_lookup("department"), protocol.pi.professional_org_lookup("division")].compact.join("/") : nil) # 8
                  data << protocol.billing_business_managers.map(&:full_name).join(',') # 9
                  data << procedure.service.organization.name # 10
                  data << procedure.service_name # 11
                  data << format_date(procedure.completed_date) # 12 service completion date
                  data << nil # 13 fulfillment date
                  data << nil # 14 performed by
                  data << nil # 15 components
                  data << nil # 16 contact
                  data << nil # 17 account number
                  data << participant.full_name # 18 patient name
                  data << (participant.label || protocols_participant.label) # 19 patient id
                  data << (appointment.name || procedure.appointment.name) # 20 visit name
                  data << (format_date(appointment.start_date) || format_date(procedure.appointment.start_date)) # 21 visit date
                  data << procedure.notes.map(&:comment).join(' | ') # 22
                  data << service_group.size # 23
                  data << nil # 24 quantity type
                  data << procedure.service.current_effective_pricing_map.unit_type # 25 clinical quantity type
                  data << display_cost(procedure.service_cost) # 26 research rate
                  data << display_cost(service_group.size * procedure.service_cost.to_f) # 27 total cost
                  data << display_pppv_modified_rate_column(procedure) # 28 modified rate
                  data << (procedure.percent_subsidy ? display_subsidy_percent(procedure) : nil) # 29 percent subsidy
                  data << (procedure.invoiced? ? "Yes" : "No") # 30
                  data << (procedure.invoiced_date ? format_date(procedure.invoiced_date) : nil)# 31

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
