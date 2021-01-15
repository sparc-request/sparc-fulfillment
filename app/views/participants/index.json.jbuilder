json.total @total
json.rows @participants do |participant|
  json.cache! participant, expires_in: 5.minutes do
    json.partial! 'participant', participant: participant
  end
end