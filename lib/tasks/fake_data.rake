require 'faker'

namespace :data do
  desc "create fake data in cwf"
  task :generate_data => :environment do
    def rand
      1 + Random.rand(10)
    end

    def sparc_id
      1 + Random.rand(1000000)
    end

    def rand_date
      (Date.today - Random.rand(100).years) - Random.rand(365).days
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

    def rand_address
      Random.rand(10).to_s + " " + Faker::Lorem.word + " " + ["way", "st", "lane"].sample
    end

    def rand_phone
      Random.rand(100..999).to_s + "-" + Random.rand(100..999).to_s + "-" + Random.rand(1000..9999).to_s
    end

    def protocol_status
      ['All', 'Draft', 'Submitted', 'Get a Quote', 'In Process', 'Complete', 'Awaiting Requester Response', 'On Hold'].sample
    end

    def rand_core
      ['RCM', 'Nexus', 'Something', 'Or Other'].sample
    end

    services = []
    for i in 0...10
      services << Service.create(sparc_id: sparc_id, cost: rand, name: rand_string, abbreviation: rand_string, description: rand_string)
    end

    #create protocols
    for i in 0...10
      protocol = Protocol.create(sparc_id: sparc_id, title: rand_string, short_title: rand_string, sponsor_name: rand_string, udak_project_number: rand, start_date: today, end_date: not_today, recruitment_start_date: today, recruitment_end_date: not_today, irb_status: rand_string, irb_approval_date: today, irb_expiration_date: not_today, stored_percent_subsidy: rand.to_f, study_cost: Random.rand(10000...50000), status: protocol_status)
      for a in 0...3
        arm = Arm.create(sparc_id: sparc_id, protocol_id: protocol.id, name: rand_string, visit_count: rand, subject_count: rand)
        Participant.create(protocol_id: protocol.id, arm_id: arm.id, first_name: rand_string, last_name: rand_string, mrn: rand, status: Participant::STATUS_OPTIONS.sample, date_of_birth: rand_date, gender: Participant::GENDER_OPTIONS.sample, ethnicity: Participant::ETHNICITY_OPTIONS.sample, race: Participant::RACE_OPTIONS.sample, address: rand_address, phone: rand_phone)
        for vg in 0...arm.visit_count
          visit_group = VisitGroup.create(sparc_id: sparc_id, arm_id: arm.id, position: vg+1, name: rand_string, day: today, window_before: rand, window_after: rand)
        end
        for li in 0...rand
          #for the service_id, it simply uses the counting index so each lineitem created there won't be duplicate services
          line_items = LineItem.create(sparc_id: sparc_id, arm_id: arm.id, service_id: services[li].id, sparc_core_name: rand_core)
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
