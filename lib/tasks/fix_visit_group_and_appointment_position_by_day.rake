namespace :data do

  desc 'Fix Visit Group and Appointment Position by Day'
  task fix_visit_group_position: :environment do
  	Protocol.all.each do |protocol|
  		protocol.arms.each do |arm|
  			fix_visit_group_positions(arm)
        fix_appointment_positions(arm)
  		end
  	end
  end
end

def sort_visit_groups_by_day arm
  arm.visit_groups.sort_by {|vg| vg.day}
end

def fix_visit_group_positions arm
  visit_groups = sort_visit_groups_by_day(arm)
  position = 0

  visit_groups.each do |vg|
    vg.update_attributes(position: position)
    position += 1
  end
end

def fix_appointment_positions arm
  arm.appointments.each do |app|
    vg_id = app.visit_group_id
    vg    = VisitGroup.find(vg_id)
    app.update_attributes(visit_group_position: vg.position)
    app.update_attributes(position: vg.position)
  end
end
