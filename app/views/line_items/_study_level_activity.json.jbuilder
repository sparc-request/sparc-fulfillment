json.(line_item)

json.id line_item.id
json.service line_item.service.name
json.quantity_requested line_item.quantity_requested
json.quantity_type line_item.quantity_type
json.quantity_remaining line_item.quantity_remaining
json.account_number line_item.account_number
json.contact line_item.contact_name
json.date_started format_date(line_item.started_at)
json.service_components sla_components_select(line_item.id, line_item.components.with_deleted)
json.last_fulfillment format_date(line_item.last_fulfillment)
json.options sla_options_buttons(line_item.id)
json.fulfillments_button fulfillments_drop_button(line_item.id)
