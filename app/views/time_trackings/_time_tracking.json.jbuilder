is_active = time_tracking.ended_at.nil?

json.id time_tracking.id
json.is_active is_active
json._class 'table-warning' if is_active

json.srid time_tracking.protocol&.srid
json.raw_srid time_tracking.protocol ? sprintf("%08d%06d", time_tracking.protocol.sparc_id.to_i, time_tracking.protocol.sub_service_request&.ssr_id.to_i) : ''
json.rmid time_tracking.protocol&.research_master_id
json.status time_tracking.protocol ? formatted_status(time_tracking.protocol) : '-'

display_title = @working_titles[time_tracking.protocol_id].presence || time_tracking.protocol&.short_title
json.short_title content_tag(:span, display_title, class: 'd-inline-block text-truncate', style: 'max-width: 200px;', title: display_title)

json.pi time_tracking.protocol&.pi&.full_name
json.service_name content_tag(:span, time_tracking.line_item&.service&.name, class: 'd-inline-block text-truncate', style: 'max-width: 200px;', title: time_tracking.line_item&.service&.name)

json.component_name time_tracking.component_name
json.start_time time_tracking.started_at&.strftime('%l:%M %p')&.strip
json.end_time time_tracking.ended_at&.strftime('%l:%M %p')&.strip
json.notes time_tracking.notes.present? ? content_tag(:span, time_tracking.notes, class: 'd-inline-block text-truncate', style: 'max-width: 200px', title: time_tracking.notes) : ''

if is_active
  start_time_str = time_tracking.started_at&.strftime('%l:%M %p')&.strip
  running_text   = start_time_str ? "Running... #{start_time_str}" : "Running..."
  json.quantity "<span class=\"text-muted\">#{running_text}</span>"
  json.raw_quantity 999999.0
  json.date ""

  json.raw_date '99999999'
  json.actions link_to(
    'Stop',
    stop_time_tracking_path(time_tracking),
    method: :put,
    remote: true,
    class: 'btn btn-sm btn-danger py-0 px-2 font-weight-bold',
    title: 'Stop'
  )
else
  json.quantity number_with_precision(time_tracking.quantity, precision: 2)
  json.raw_quantity time_tracking.quantity.to_f
  json.date time_tracking.date&.strftime('%m/%d/%Y')
  json.raw_date time_tracking.date&.strftime('%Y%m%d')

  edit_btn = link_to(
    icon('fas', 'edit'),
    edit_time_tracking_path(time_tracking),
    remote: true,
    class: 'btn btn-sm btn-link text-primary p-1',
    title: 'Edit'
  )

  delete_btn = link_to(
    icon('fas', 'trash-alt'),
    time_tracking_path(time_tracking),
    method: :delete,
    remote: true,
    data: { confirm_swal: 'true', text: 'Are you sure you want to delete this time entry?' },
    class: 'btn btn-sm btn-link text-danger p-1',
    title: 'Delete'
  )

  json.actions "#{edit_btn} #{delete_btn}"
end
