module StudyScheduleManagementHelper
  def move_to_position_options_for(selected)
    selected.arm.visit_groups.where.not(id: selected.id).map do |visit_group|
      ["Before " + visit_name_with_day(visit_group), visit_group.position < selected.position ? visit_group.position : visit_group.position - 1]
    end << ["Add as last", selected.arm.visit_groups.size]
  end

  def insert_to_position_options(visit_groups)
    visit_groups.map do |visit_group|
      ["Before " + visit_name_with_day(visit_group), visit_group.position]
    end << ["Add as last", nil]
  end

  def edit_visit_options(visit_groups)
    visit_groups.map do |visit_group|
      [visit_name_with_day(visit_group), visit_group.id]
    end
  end

  private

  def visit_name_with_day(visit_group)
    visit_group.name + (!visit_group.day.nil? ? " (Day #{visit_group.day})" : "")
  end
end
