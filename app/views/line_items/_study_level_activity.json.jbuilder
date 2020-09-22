json.(line_item)

json.id                         line_item.id
json.fulfillments_button        fulfillments_drop_button(line_item)
json.service                    service_name_display(line_item.service)
json.quantity_requested         line_item.quantity_requested
json.quantity_type              line_item.quantity_type
json.fulfilled                  amount_fulfilled(line_item)
json.quantity_remaining         line_item.quantity_remaining
json.account_number             line_item.account_number
json.contact                    line_item.contact_name
json.date_started               format_date(line_item.started_at)
json.last_fulfillment           format_date(line_item.last_fulfillment)
json.notes                      sla_notes_button(line_item)
json.docs                       sla_docs_button(line_item)
json.edit                       sla_edit_button(line_item)
