json.array! @team_time_trackings do |tt|
  status_str = tt.current_status

  badge_class =
    case status_str
    when TimeTracking::IN_PROGRESS then 'badge-primary'
    when TimeTracking::UNDER_REVIEW then 'badge-warning text-dark'
    when TimeTracking::READY then 'badge-success'
    when TimeTracking::IMPORTED then 'badge-secondary'
    else 'badge-light text-dark'
    end

  json.id tt.id
  json.state false
  json.identity_id tt.identity_id
  json.staff_name tt.identity&.full_name || 'Unknown'
  json.srid tt.protocol&.srid
  json.raw_srid tt.protocol ? sprintf("%08d%06d", tt.protocol.sparc_id.to_i, tt.protocol.sub_service_request&.ssr_id.to_i) : ''
  json.short_title content_tag(:span, tt.protocol&.short_title, class: 'd-inline-block text-truncate', style: 'max-width: 200px;', title: tt.protocol&.short_title)
  json.service_name content_tag(:span, tt.line_item&.service&.name, class: 'd-inline-block text-truncate', style: 'max-width: 200px;', title: tt.line_item&.service&.name)
  json.component_name tt.component_name
  json.date tt.date&.strftime('%m/%d/%Y')
  json.raw_date tt.date&.strftime('%Y%m%d')
  json.quantity number_with_precision(tt.quantity, precision: 2)
  json.raw_quantity tt.quantity.to_f
  json.status_name status_str
  json.status content_tag(:span, status_str, class: "badge #{badge_class} px-2 py-1")
  json.notes content_tag(:span, tt.notes, class: 'd-inline-block text-truncate', style: 'max-width: 200px;', title: tt.notes)
  json.actions link_to('View', edit_time_tracking_path(tt), remote: true, class: 'btn btn-sm btn-primary py-0 px-2')
end
