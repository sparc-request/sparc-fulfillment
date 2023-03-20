namespace :data do
  desc 'Add invoiced_date value to fulfillments and procedures that have been previously flagged as invoiced'
  task add_invoiced_date_to_fulfillments_and_procedures: :environment do
    puts "*"*10 + " Adding invoiced_date to invoiced fulfillments... " + "*"*10
    bar = ProgressBar.new(Fulfillment.count)
    invoiced_fulfillments = Fulfillment.joins(:notes).where(invoiced: true)
    invoiced_fulfillments.find_each do |fulfillment|
      begin
        date = fulfillment.notes.last.updated_at
        fulfillment.update_attributes invoiced_date: date

        bar.increment! rescue nil

      rescue => exception
        puts "Error with #{fulfillment.id}, Message: #{exception.message}"
        bar.increment! rescue nil
        next
      end
    end
    puts "*"*10 + " #{invoiced_fulfillments.count} fulfillment records updated. " + "*"*10

    puts "*"*10 + " Adding invoiced_date to invoiced procedures... " + "*"*10
    bar = ProgressBar.new(Procedure.count)
    invoiced_procedures = Procedure.joins(:notes).where(invoiced: true)
    invoiced_procedures.find_each do |procedure|
      begin
        date = procedure.notes.last.updated_at
        procedure.update_attributes invoiced_date: date
        bar.increment! rescue nil
      rescue => exception
        puts "Error with #{procedure.inspect}, Message: #{exception.message}"
        bar.increment! rescue nil
        next
      end
    end
    puts "*"*10 + " #{invoiced_procedures.count} procedure records updated. " + "*"*10
  end
end
