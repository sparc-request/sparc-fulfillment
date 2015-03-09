json.(participant)

json.protocol_id participant.protocol_id
json.name participant.first_name + ' ' + participant.last_name
json.mrn participant.mrn
json.external_id participant.external_id
json.id participant.id
json.status participant.status
json.protocol_sparc_id participant.protocol.sparc_id
json.coordinators formatted_coordinators(participant.protocol.coordinators.map(&:full_name))
json.recruitment_source participant.recruitment_source

if participant.arm
  json.arm participant.arm.name
else
  json.arm 'None'
end
