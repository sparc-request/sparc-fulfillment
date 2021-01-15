json.(protocols_participant)

json.actions            protocols_participant_actions(protocols_participant)
json.arm                protocols_participant_arm_dropdown(protocols_participant)
json.calendar           protocols_participant_calendar_button(protocols_participant)
json.external_id        protocols_participant_external_id(protocols_participant)
json.first_middle       protocols_participant.participant.first_middle
json.last_name          protocols_participant.participant.last_name
json.mrn                protocols_participant.participant.mrn
json.notes              notes_button(protocols_participant.participant, tooltip: t('participants.tooltips.notes'))
json.recruitment_source protocols_participant_recruitment_source_dropdown(protocols_participant)
json.status             protocols_participant_status_dropdown(protocols_participant)
