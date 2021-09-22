json.(line_item)

json.id                   line_item.id
json.fulfillments         sla_fulfillments_button(line_item)
json.service              service_name_display(line_item.service)
json.quantity_requested   line_item.quantity_requested
json.quantity_type        line_item.quantity_type
json.fulfilled            amount_fulfilled(line_item)
json.quantity_remaining   line_item.quantity_remaining
json.account_number       sla_account_number(line_item)
json.contact              sla_contact(line_item)
json.date_started         format_date(line_item.started_at)
json.last_fulfillment     format_date(line_item.last_fulfillment)
json.notes                notes_button(line_item)
json.documents            sla_docs_button(line_item)
