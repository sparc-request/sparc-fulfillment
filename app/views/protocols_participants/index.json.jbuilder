json.total @total
json.rows @protocols_participants do |protocols_participant|
  json.cache! protocols_participant, expires_in: 5.minutes do
    json.partial! 'protocols_participant', protocols_participant: protocols_participant
  end
end
