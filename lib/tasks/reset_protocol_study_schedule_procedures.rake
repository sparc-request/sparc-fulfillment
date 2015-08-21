namespace :data do
  desc 'Reset participant procedures to current study schedule R and T quantities'
  task reset_participant_procedures: :environment do
    
    print "Which protocol would you like me to reset: "
    protocol_id = STDIN.gets.chomp

    print "Are you sure you want to reset #{protocol_id.to_i}? (Yes/No) "
    answer = STDIN.gets.chomp

    if answer == 'Yes'
      protocol = Protocol.find protocol_id.to_i

      puts "Gathering up per participant line items"
      line_items = protocol.line_items.includes(:service).where(:services => {:one_time_fee => false})
      bar = ProgressBar.new(line_items.count)

      line_items.each do |line_item|
        line_item.visits.each do |visit|
          visit.update_procedures visit.research_billing_qty, 'research_billing_qty'
          visit.update_procedures visit.insurance_billing_qty, 'insurance_billing_qty'
        end

        bar.increment! rescue nil
      end

      puts "Gathering up procedures"
      procedures = protocol.procedures
      bar = ProgressBar.new(procedures.count)
      
      procedures.each do |procedure|
        sparc_core = Organization.find procedure.sparc_core_id
        procedure.update_attribute(:sparc_core_name, sparc_core.name)

        bar.increment! rescue nil
      end
    else
      puts "Task aborted!"
    end
  end
end
