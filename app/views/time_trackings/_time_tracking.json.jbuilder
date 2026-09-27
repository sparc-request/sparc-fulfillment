is_active = time_tracking.ended_at.nil?

json.id time_tracking.id
json.is_active is_active
json._class 'table-warning' if is_active

json.srid time_tracking.protocol&.srid
json.rmid time_tracking.protocol&.research_master_id
json.status time_tracking.protocol&.status&.capitalize
json.short_title content_tag(:span, time_tracking.protocol&.short_title, class: 'd-inline-block text-truncate', style: 'max-width: 200px;', title: time_tracking.protocol&.short_title)

json.pi time_tracking.protocol&.pi&.full_name
json.service_name content_tag(:span, time_tracking.line_item&.service&.name, class: 'd-inline-block text-truncate', style: 'max-width: 200px;', title: time_tracking.line_item&.service&.name)

json.component_name time_tracking.component_name

if is_active
  json.quantity '<span class="text-muted">Running...</span>'
  json.raw_quantity 999999.0
  json.date "<span class=\"text-muted\">#{time_tracking.started_at&.strftime('%I:%M %p')}</span>"

  json.raw_date '99999999'
  json.actions link_to('Stop', stop_time_tracking_path(time_tracking), method: :put, remote: true, class: 'btn btn-sm btn-danger font-weight-bold')
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
    icon('fas', 'trash'),
    time_tracking_path(time_tracking),
    method: :delete,
    remote: true,
    data: { confirm: 'Are you sure?' },
    class: 'btn btn-sm btn-link text-danger p-1 ml-1',
    title: 'Delete'
  )

  json.actions "#{edit_btn} #{delete_btn}"
end
