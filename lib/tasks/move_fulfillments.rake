task move_fulfillments: :environment do

  protocol = Protocol.find(2183)
  dup_protocol = Protocol.find_by_sparc_id(8170)
  line_item = LineItem.where(protocol_id: protocol.id).first
  dup_line_item = LineItem.where(protocol_id: dup_protocol.id).first

  puts 'Preparing to move fulfillments'
  dup_line_item.fulfillments.each do |fulfillment|
    puts "#" * 20
    puts "Moving fulfillment #{fulfillment.id}"
    puts "from line item with an id of #{dup_line_item.id}"
    puts "to line item with an id of #{line_item.id}"
    fulfillment.update_attributes(line_item_id: line_item.id)
  end

  dup_protocol.destroy
end