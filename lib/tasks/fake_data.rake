require 'faker'

namespace :data do
  desc "create fake data in cwf"
  task :generate_data => :environment do
    def rand
      1 + Random.rand(10)
    end

    def sparc_id
      1 + Random.rand(100000)
    end

    def today
      Time.now
    end

    def not_today
      Time.now + 10.days
    end

    def rand_string
      Faker::Lorem.word
    end

    statuses = ['Completed', 'Nexus Approved']

    services = []
    for i in 0...10
      services << Service.create(sparc_id: sparc_id, cost: rand, name: rand_string, abbreviation: rand_string, description: rand_string)
    end

    #create protocols 
    for i in 0...10
      protocol = Protocol.create(sparc_id: sparc_id, title: rand_string, short_title: rand_string, sponsor_name: rand_string, udac_project_number: rand, requester_id: sparc_id, start_date: today, end_date: not_today, recruitment_start_date: today, recruitment_end_date: not_today, irb_status: rand_string, irb_approval_date: today, irb_expiration_date: not_today, subsidy_amount: rand, study_cost: rand, status: statuses[i%2])
      for a in 0...3
        arm = Arm.create(sparc_id: sparc_id, protocol_id: protocol.id, name: rand_string, visit_count: rand, subject_count: rand)
        for vg in 0...arm.visit_count
          visit_group = VisitGroup.create(sparc_id: sparc_id, arm_id: arm.id, position: rand, name: rand_string, day: today, window_before: rand, window_after: rand)
        end
        for li in 0...rand
          #for the service_id, it simply uses the counting index so each lineitem created there won't be duplicate services
          line_items = LineItem.create(sparc_id: sparc_id, arm_id: arm.id, service_id: services[li].id, name: rand_string, cost: rand)
        end
        arm.visit_groups.each do |vg|
          arm.line_items.each do |li|
            visit = Visit.create(sparc_id: sparc_id, line_item_id: li.id, visit_group_id: vg.id, research_billing_qty: rand, insurance_billing_qty: rand, effort_billing_qty: rand)
          end
        end
      end
    end
  end
end