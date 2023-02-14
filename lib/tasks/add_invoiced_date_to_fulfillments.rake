namespace :data do
  desc 'Add invoiced_date value to fulfillments that have been flagged as invoiced'
  task add_invoiced_date_to_fulfillments: :environment do
    puts "*"*10 + " Adding invoiced_date to invoiced fulfillments... " + "*"*10
    bar = ProgressBar.new(Fulfillment.count)
    invoiced_fulfillments = Fulfillment.joins(:notes).where(invoiced: true)
    invoiced_fulfillments.find_each do |fulfillment|
      begin
        date = fulfillment.notes.last.updated_at
        fulfillment.update_attributes invoiced_date: date

        bar.increment! rescue nil

      rescue Exception => e
        puts "Error with #{fulfillment.inspect}, Message: #{e.message}"
        bar.increment! rescue nil
        next
      end
    end
    puts "*"*10 + " #{invoiced_fulfillments.count} fulfillment records updated. " + "*"*10
  end
end
