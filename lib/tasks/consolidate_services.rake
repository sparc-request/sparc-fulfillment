namespace :data do
  desc 'Replace X number of services with 1 service'
  task consolidate_services: :environment do

    def main
      old_service_ids, new_service_id = get_user_input

      #Make sure that both

      if !(old_service_ids.empty? && new_service_id.nil?) && new_service_id > 0
        if services_can_be_swapped?(old_service_ids, new_service_id)
          print "This will change the Service ID of Visits, Incomplete, and Unstarted Procedures with Service IDs = #{old_service_ids} to Service ID = '#{new_service_id}'. Is this correct? Y/N? "
          ok_with_values = STDIN.gets.chomp

          if "Yes".casecmp(ok_with_values).zero? || "Y".casecmp(ok_with_values).zero?
            update_procedures(old_service_ids, new_service_id)
          elsif "No".casecmp(ok_with_values).zero? || "N".casecmp(ok_with_values).zero?
            puts "Service IDs will not be changed."
          end
        else
          puts "These services are associated with different organizations and can't be swapped."
        end
      else
        puts "Invalid values were entered."
      end

      puts "Exiting rake task."
    end

    def get_user_input
      print "What are the IDs of the services to be replaced? (eg. 1,2,3) "
      old_service_ids = STDIN.gets.chomp.split(",").map(&:strip) rescue []

      print "What is the ID of the new service? (eg. 4) "
      new_service_id = Integer( STDIN.gets.chomp ) rescue nil

      return old_service_ids, new_service_id
    end

    def services_can_be_swapped?(old_service_ids, new_service_id)
      same_parent = get_process_ssr_org(old_service_ids) == get_process_ssr_org(new_service_id)
      puts "Checking that all services have the same process_ssrs parent: #{same_parent}"
      same_parent
    end

    def get_process_ssr_org(service_ids)
      services = Service.where(id: service_ids).distinct(:organization_id).group(:organization_id)

      orgs = []
      services.each do |service|
        organization = service.organization

        while !organization.process_ssrs
          organization = organization.parent
        end

        orgs << organization
      end

      puts "Service IDs #{service_ids} belong to #{orgs.uniq.map(&:name)}"

      orgs.uniq
    end

    def update_procedures(old_service_ids, new_service_id)
      Visit.transaction do
        CSV.open("tmp/consolidate_service.csv", "wb") do |csv|
          all_visits = Visit.includes(:line_item).where(line_items: {service_id: old_service_ids}).group_by{|v| v.visit_group_id}

          puts "Fixing study calendars first"

          all_visits.each do |visit_group_id, visits|
            total_r_qty = visits.sum(&:research_billing_qty)
            total_i_qty = visits.sum(&:insurance_billing_qty)
            total_e_qty = visits.sum(&:effort_billing_qty)

            first = visits.delete_at(0) # are going to smash them all in to this one visit

            visit_new_attributes = {research_billing_qty: total_r_qty, insurance_billing_qty: total_i_qty, effort_billing_qty: total_e_qty}
            line_item_new_attributes = {service_id: new_service_id}

            csv << ["update", 'Visit', first.attributes, visit_new_attributes]
            csv << ["update", 'LineItem', first.line_item.attributes, line_item_new_attributes]

            first.update_attributes(visit_new_attributes)
            first.line_item.update_attributes(line_item_new_attributes)

            visits.each do |visit|
              csv << ["destroy", 'LineItem', visit.line_item.attributes]
              csv << ["destroy", 'Visit', visit.attributes]
              visit.line_item.destroy
              visit.destroy
            end
          end

          puts "Fixing procedures"

          procs = Procedure.where(service_id: old_service_ids, status: ["unstarted", "incomplete"])
          new_service = Service.find new_service_id

          procs.each do |procedure|
            new_attributes = {service_id: new_service.id, service_name: new_service.name}
            csv << ["update", 'Procedure', procedure.attributes, new_attributes]

            procedure.update_attributes(new_attributes)
          end
        end
      end
    end

    main
  end
end
