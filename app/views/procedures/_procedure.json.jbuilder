json.(procedure)

json.actions        procedure_actions(procedure, appointment_style)
json.billing_type   procedure_billing_display(procedure)
json.completed_date render 'completed_date.html', procedure: procedure
json.credited       procedure_credited_display(procedure)
json.followup       render 'followup.html', procedure: procedure
json.group_label    procedure_group_label(procedure, true)
json.invoiced       procedure_invoiced_display(procedure)
json.invoiced_date  invoiced_date(procedure)
json.name           procedure_name_display(procedure)
json.notes          procedure_notes_display(procedure)
json.performer      procedure_performer_display(procedure, performable_by)
json.status         render 'status_toggle.html', procedure: procedure
