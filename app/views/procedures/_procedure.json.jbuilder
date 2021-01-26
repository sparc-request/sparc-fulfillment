json.(procedure)

json.actions        ""
json.billing_type   procedure_billing_display(procedure)
json.completed_date render 'completed_date.html', procedure: procedure
json.credited       procedure.credited? ? t('constants.yes_select') : t('constants.no_select')
json.followup       render 'followup.html', procedure: procedure
json.invoiced       procedure.invoiced? ? t('constants.yes_select') : t('constants.no_select')
json.name           service_name_display(procedure.service)
json.notes          notes_button(procedure)
json.performer      procedure_performer_display(procedure)
json.status         render 'status_toggle.html', procedure: procedure
