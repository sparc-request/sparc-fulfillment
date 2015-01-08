class LineItemVisitsImporter < DependentObjectImporter

  def line_item
    object
  end

  private

  def create_dependents
    new_visit_columns = [:visit_group_id, :line_item_id, :research_billing_qty, :insurance_billing_qty, :effort_billing_qty]
    new_visit_values  = []

    visit_group_ids.each do |visit_group_id|
      new_visit_values.push [visit_group_id, object.id, 0, 0, 0]
    end

    Visit.import new_visit_columns, new_visit_values, { validate: true }
  end

  def visit_group_ids
    object.visit_groups.pluck(:id)
  end
end
