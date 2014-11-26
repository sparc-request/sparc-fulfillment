module ProtocolHelper
  def arms_for_select protocol, selected_arm
    arr = protocol.arms.map { |arm| [ arm.name, arm.id ] }
    options_for_select(arr, selected_arm.id)
  end

  def visit_groups_for_select selected_arm, selected_visit_group
    visit_groups = VisitGroup.where arm_id: selected_arm.id
    puts visit_groups.inspect
    arr = visit_groups.map { |vg| [ vg.name, vg.id ] }
    options_for_select arr, selected_visit_group
  end

  def services_for_select
    services = Service.all
    arr = services.map {|s| [s.name, s.id] }
    
    arr
  end
end
