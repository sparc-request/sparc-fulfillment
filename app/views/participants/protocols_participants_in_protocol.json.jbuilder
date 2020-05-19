json.total @total
json.rows @participants do |participant|
  protocols_participant = ProtocolsParticipant.where(participant_id: participant.id, protocol_id: @protocol.id).first
  json.cache! protocols_participant, expires_in: 5.minutes do
    json.id participant.id
    json.protocol_id protocols_participant.protocol_id
    json.srid @protocol.srid
    json.arm_id protocols_participant.arm_id
    json.arm_name truncated_formatter(protocols_participant.arm.nil? ? "" : protocols_participant.arm.name)
    json.first_middle truncated_formatter(participant.first_middle)
    json.first_name truncated_formatter(participant.first_name)
    json.middle_initial participant.middle_initial
    json.last_name truncated_formatter(participant.last_name)
    json.name truncated_formatter(participant.full_name)
    json.mrn truncated_formatter(participant.mrn)
    json.external_id truncated_formatter(participant.external_id)
    json.statusText protocols_participant.status
    json.statusDropdown statusFormatter(participant, protocols_participant, @protocol.id)
    json.notes notes_formatter(participant)
    json.date_of_birth format_date(participant.date_of_birth)
    json.gender participant.gender
    json.ethnicity participant.ethnicity
    json.race participant.race
    json.address truncated_formatter(participant.address)
    json.phone phoneNumberFormatter(participant)
    json.details detailsFormatter(participant, protocols_participant)
    json.edit editFormatter(participant, protocols_participant)
    json.delete deleteFormatter(participant, protocols_participant)
    json.calendar calendarFormatter(protocols_participant)
    json.participant_report participant_report_formatter(protocols_participant)
    json.chg_arm changeArmFormatter(participant, protocols_participant)
    json.recruitment_source truncated_formatter(participant.recruitment_source)
    json.coordinators formatted_coordinators(@protocol.coordinators.map(&:full_name))
  end
end
