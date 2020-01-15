desc "Script to fix data after the IDS split/notify move"
task :fix_split_notify => :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def get_file(error=false)
    puts "No import file specified or the file specified does not exist in db/imports" if error
    file = prompt "Please specify the file name to import from db/imports (must be a CSV): "

    while file.blank? or not File.exists?(Rails.root.join("db", "imports", file))
      file = get_file(true)
    end

    file
  end

  #need to save all duplicated objects
  def create_calendar_data(protocol, line_item)
    puts "Creating new calendar data"
    old_arm = line_item.arm
    new_arm = old_arm.dup
    new_arm.save(validate: false)
    line_item.update_attributes(arm_id: new_arm.id)
    new_arm.update_attributes(protocol_id: protocol.id)
    old_arm.visit_groups.each do |vg|
      new_vg = vg.dup
      new_vg.arm_id = new_arm.id
      new_vg.save(validate: false)
      vg.visits.each do |visit|
        new_visit = visit.dup
        new_visit.visit_group_id = new_vg.id
        new_visit.line_item_id = line_item.id
        new_visit.save(validate: false)
      end
    end
  end

  puts ""
  puts "Reading in file..."
  input_file = Rails.root.join("db", "imports", get_file)
  continue = prompt('Preparing to modify the data. Are you sure you want to continue? (y/n): ')
  if (continue == 'y') || (continue == 'Y')
    ActiveRecord::Base.transaction do
      CSV.open("tmp/line_item_comparison_report.csv", "w+") do |csv|
        csv << ['Assigned or created', 'Sparc ID', 'Sparc line item count', 'Cwf line item count', 'Reason Skipped']
        CSV.foreach(input_file, :headers => true) do |row|
          line_item_array = LineItem.where(sparc_id: row['Line Item ID'].to_i)
          line_item = line_item_array.first
          
          if line_item
            if row['Assigned or Created'] == 'Created'
              puts "Creating new protocol"
              protocol = Protocol.new(sparc_id: row['Sparc ID'].to_i, sponsor_name: row['Sponsor Name'],
                                         udak_project_number: row['Udak Number'], start_date: row['Start Date'],
                                         end_date: row['End Date'], recruitment_start_date: row['recruitment_start'],
                                         recruitment_end_date: row['Recruitment End'], study_cost: row['Study Cost'].to_i,
                                         sub_service_request_id: row['New SSR ID'].to_i)
              if protocol.valid?
                protocol.save
                line_item.update_attributes(protocol_id: protocol.id)
                create_calendar_data(protocol, line_item) if (row['Is One Time Fee?'] == 'false')
                csv << [row['Assigned or Created'], "#{protocol.sub_service_request_id}", row['Line Item Count'], "#{protocol.line_items.count}", ""]
              else
                puts "#"*50
                puts "Error importing protocol"
                puts protocol.errors.inspect
              end  
            else
              puts 'Assigning to existing protocol'
              protocol = Protocol.where(sub_service_request_id: row['New SSR ID'].to_i).first
              line_item.update_attributes(protocol_id: protocol.id)
              csv << [row['Assigned or Created'], "#{protocol.sub_service_request_id}", row['Line Item Count'], "#{protocol.line_items.count}", ""]
            end
          else
            deleted_line_item = LineItem.with_deleted.where(sparc_id: row['Line Item ID'].to_i).first

            if deleted_line_item
              csv << ["","","","","Line item #{row['Line Item ID']} deleted on cwf side"]
              puts "Line item #{row['Line Item ID']} belonging to SSR #{row['New SSR ID']} deleted on cwf side"
            else
              csv << ["","","","","No line item found for Line item ID #{row['Line Item ID']} belonging to SSR #{row['New SSR ID']}"]
              puts "No line item found for Line item ID #{row['Line Item ID']} belonging to SSR #{row['New SSR ID']}"
            end
          end 
        end
      end
    end
  end
end