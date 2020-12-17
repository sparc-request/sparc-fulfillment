json.(participant)

if @protocol
  json.associate protocols_participant_associate_check(participant, @protocol)
else
  json.details  registry_details_formatter(participant)
  json.edit     registry_edit_formatter(participant)
  json.delete   registry_delete_formatter(participant)
end

json.deidentified   deidentified_patient(participant)
json.first_middle   participant.first_middle
json.last_name      participant.last_name
json.mrn            participant.mrn
json.phone          phoneNumberFormatter(participant)
