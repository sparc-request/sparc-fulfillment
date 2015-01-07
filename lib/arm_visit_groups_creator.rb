class ArmVisitGroupsCreator

  attr_accessor :arm

  def initialize(arm)
    @arm = arm
  end

  def create
    if @arm.save!
      create_visit_groups
    end
  end

  def create_visit_groups
    new_visit_group_columns = [:name, :day, :position, :arm_id]
    new_visit_group_values  = []

    arm.visit_count.times do |index|
      name = "Visit #{index}"

      new_visit_group_values.push [name, index, index, @arm.id]
    end

    VisitGroup.import new_visit_group_columns, new_visit_group_values, { validate: true }
  end
end
