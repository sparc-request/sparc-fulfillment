json.total @total

json.rows @protocols do |protocol|
  json.cache! protocol, expires_in: 5.minutes do
    json.sparc_id               protocol.sparc_id
    json.srid                   protocol.srid + link_to('', protocol_path(protocol), class: 'd-none')
    json.rmid                   protocol.research_master_id
    json.status                 formatted_status(protocol)
    json.short_title            protocol.short_title
    json.irb_approval_date      format_date(protocol.irb_approval_date)
    json.irb_expiration_date    format_date(protocol.irb_expiration_date)
    json.udak_project_number    protocol.udak_project_number
    json.irb_number             protocol.irb_number
    json.start_date             format_date(protocol.start_date)
    json.end_date               format_date(protocol.end_date)
    json.total_at_approval      display_cost(protocol.total_at_approval.to_i)
    json.percent_subsidy        (protocol.percent_subsidy.to_f * 100.0).round(2)
    json.subsidy_committed      display_cost(protocol.subsidy_committed || 0.0)
    json.pi                     protocol.pi.full_name
    json.coordinators           formatted_coordinators(protocol.coordinators.map(&:full_name))
    json.study_schedule_report  formatted_study_schedule_report(protocol)
    json.owner                  formatted_owner(protocol)
    json.requester              formatted_requester(protocol)
    json.organizations          protocol.sub_service_request.org_tree_display
  end
end

