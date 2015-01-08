class ArmVisitGroupsImporter < DependentObjectImporter

  def arm
    object
  end

  private

  def create_dependents
    new_visit_group_columns = [:name, :day, :position, :arm_id]
    new_visit_group_values  = []

    object.visit_count.times do |index|
      name = "Visit #{index}"

      new_visit_group_values.push [name, index, index, object.id]
    end

    VisitGroup.import new_visit_group_columns, new_visit_group_values, { validate: true }
  end
end
