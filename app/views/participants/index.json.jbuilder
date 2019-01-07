json.total @total
#json.(participant)
json.rows @participants do |participant|
  json.cache! participant, expires_in: 5.minutes do
    json.id participant.id
    json.selected_for_protocol selected_for_protocol_formatter(participant, @protocol)
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
    json.address truncated_formatter(participant.address)
    json.phone phoneNumberFormatter(participant)
    json.details detailsFormatter(participant)
    json.edit editFormatter(participant)
    json.delete deleteFormatter(participant)
  end
end