json.rows [@protocol] do |protocol|
  json.partial! 'protocol', protocol: protocol
end
