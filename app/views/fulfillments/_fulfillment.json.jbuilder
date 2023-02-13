json.(fulfillment)
json.id fulfillment.id
json.month_year          month_year_formatter(fulfillment)
json.fulfillment_date    fulfillment_date_formatter(fulfillment)
json.quantity            fulfillment.quantity
json.quantity_type       fulfillment.line_item.quantity_type
json.performed_by        fulfillment.performer.full_name if fulfillment.performer
json.components          fulfillment_components_formatter(fulfillment.components)
json.actions             fulfillment_actions(fulfillment)
json.invoiced            toggle_invoiced(fulfillment)
json.invoiced_date       date_invoiced_formatter(fulfillment) if fulfillment.invoiced_date
json.credited				     toggle_credited(fulfillment)
json.notes               notes(fulfillment.notes)
json.documents           documents(fulfillment.documents)
json.invoiced_export     invoice_read_only(fulfillment)
json.credited_export     credit_read_only(fulfillment)
