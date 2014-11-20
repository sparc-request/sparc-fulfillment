module ProtocolHelper
  def arms_for_select protocol, selected_arm
    arr = protocol.arms.map { |arm| [ arm.name, arm.id ] }
    options_for_select(arr, selected_arm.id)
  end

  def select_visit_groups(selected_arm)
    visit_groups = VisitGroup.all
    visit_groups.keep_if{ |vg| vg.arm_id == selected_arm.id}
    puts options_for_select(protocol.visits.map(&:name), selected_visit_group.id)
  end

  def select_services(protocol,selected)
    options_for_select(protocol.visits.map(&:name), selected)
  end
end
