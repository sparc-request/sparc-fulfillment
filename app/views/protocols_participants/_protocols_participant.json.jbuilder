json.(protocols_participant)

json.actions                  protocols_participant_actions(protocols_participant)
json.arm                      protocols_participant_arm_dropdown(protocols_participant)
json.arm_read                 protocols_participant.arm.try(:name)
json.calendar                 protocols_participant_calendar_button(protocols_participant)
json.external_id              protocols_participant_external_id(protocols_participant)
json.external_id_read         protocols_participant_external_id(protocols_participant, readonly: true)
json.first_middle             protocols_participant.first_middle
json.last_name                protocols_participant.last_name
json.mrn                      protocols_participant.mrn
json.notes                    notes_button(protocols_participant.participant, tooltip: t('participants.tooltips.notes'))
json.recruitment_source       protocols_participant_recruitment_source_dropdown(protocols_participant)
json.recruitment_source_read  protocols_participant_recruitment_source_dropdown(protocols_participant, readonly: true)
json.status                   protocols_participant_status_dropdown(protocols_participant)
json.status_read              protocols_participant_status_dropdown(protocols_participant, readonly: true)
