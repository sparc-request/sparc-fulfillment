json.total @total
json.rows @participants do |participant|
  json.cache! [@protocol, participant], expires_in: 5.minutes do
    json.id participant.id
    json.first_middle truncated_formatter(participant.first_middle)
    json.first_name truncated_formatter(participant.first_name)
    json.middle_initial participant.middle_initial
    json.last_name truncated_formatter(participant.last_name)
    json.name truncated_formatter(participant.full_name)
    json.mrn truncated_formatter(participant.mrn)
    json.external_id truncated_formatter(participant.external_id)
    json.notes notes_formatter(participant)
    json.date_of_birth format_date(participant.date_of_birth)
    json.gender participant.gender
    json.ethnicity participant.ethnicity
    json.race participant.race
    json.deidentified deidentified_patient(participant)
    json.address truncated_formatter(participant.address)
    json.phone phoneNumberFormatter(participant)
    json.edit registry_edit_formatter(participant)
    json.associate associate_formatter(participant, @protocol)
    json.recruitment_source truncated_formatter(participant.recruitment_source)
  end
end
