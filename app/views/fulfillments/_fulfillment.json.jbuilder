json.(fulfillment)

json.id fulfillment.id
json.fulfillment_grouper fulfillment_grouper_formatter(fulfillment)
json.fulfillment_date fulfillment_date_formatter(fulfillment)
json.quantity fulfillment.quantity
json.quantity_type fulfillment.line_item.quantity_type
json.performed_by fulfillment.performer.full_name if fulfillment.performer
json.components fulfillment_components_formatter(fulfillment.components)
json.options fulfillment_options_buttons(fulfillment)
json.invoiced (fulfillment.invoiced? ? "Yes" : "No")
