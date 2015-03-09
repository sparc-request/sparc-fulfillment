json.(participant)

json.protocol_id participant.protocol_id
json.name participant.first_name + ' ' + participant.last_name
json.id participant.id
json.status participant.status
json.protocol_sparc_id participant.protocol.sparc_id
json.coordinators formatted_coordinators(participant.protocol.coordinators.map(&:full_name))

if participant.arm
  json.arm participant.arm.name
else
  json.arm 'None'
end
