json.rows @procedures do |procedure|
  json.cache! procedure, expires_in: 5.minutes do
    json.partial! 'procedure', procedure: procedure
  end
end
