json.(line_item)

json.id                         line_item.id
json.service                    service_name_display(line_item.service)
json.quantity_requested         line_item.quantity_requested
json.quantity_type              line_item.quantity_type
json.quantity_remaining         line_item.quantity_remaining
json.account_number             line_item.account_number
json.contact                    line_item.contact_name
json.date_started               format_date(line_item.started_at)
json.service_components         sla_components_select(line_item.id, line_item.components.with_deleted)
json.service_components_export  line_item.components.selected.map(&:component).join(', ')
json.last_fulfillment           format_date(line_item.last_fulfillment)
json.options                    sla_options_buttons(line_item)
json.fulfillments_button        fulfillments_drop_button(line_item)
json.notes                      notes(line_item.notes)
json.docs                       documents(line_item.documents)