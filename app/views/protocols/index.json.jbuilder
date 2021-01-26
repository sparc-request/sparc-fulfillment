json.total @total
json.rows @protocols do |protocol|
  json.cache! protocol, expires_in: 5.minutes do
    json.partial! 'protocol', protocol: protocol
  end
end
