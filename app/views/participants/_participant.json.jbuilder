json.(participant)
json.id participant.id
json.protocol_id participant.protocol_id
json.arm_id participant.arm_id
json.arm_name participant.arm.name if participant.arm
json.first_name participant.first_name.humanize
json.last_name participant.last_name.humanize
json.name participant.full_name
json.mrn participant.mrn
json.external_id participant.external_id
json.status participant.status
json.date_of_birth format_date(participant.date_of_birth)
json.gender participant.gender
json.ethnicity participant.ethnicity
json.race participant.race
json.address participant.address
json.phone participant.phone
json.details detailsFormatter(participant)
json.edit editFormatter(participant)
json.delete deleteFormatter(participant)
json.calendar calendarFormatter(participant)
json.report statsFormatter(participant)
json.chg_arm changeArmFormatter(participant)
json.recruitment_source recruitment_formatter(participant)
json.coordinators formatted_coordinators(participant.protocol.coordinators.map(&:full_name))
