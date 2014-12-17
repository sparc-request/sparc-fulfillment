module ProtocolHelper

  def visit_groups_for_select(arm)
    visit_group_options = arm.visit_groups
    visit_group_options.each do |vg|
      vg.name= "insert before " + vg.name
    end
    add_last = VisitGroup.new(name: "add as last", position: visit_group_options.last.position + 1) # creates dummy visit to used as last option, it will not be saved used only for selection
    visit_group_options << add_last
    return visit_group_options
  end
end
