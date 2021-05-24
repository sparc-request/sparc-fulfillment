json.(participant)

if @protocol
  json.associate protocols_participant_associate_check(participant, @protocol)
else
  json.details  registry_details_formatter(participant)
  json.actions    registry_actions_formatter(participant)
end

json.deidentified   deidentified_patient(participant)
json.first_middle   participant.first_middle
json.last_name      participant.last_name
json.date_of_birth  participant.date_of_birth
json.mrn            participant.mrn
json.phone          phoneNumberFormatter(participant)
