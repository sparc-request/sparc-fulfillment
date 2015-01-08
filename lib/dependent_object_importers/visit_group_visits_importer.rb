class VisitGroupVisitsImporter < DependentObjectImporter

  def visit_group
    object
  end

  private

  def create_dependents
    new_visit_columns = [:visit_group_id, :line_item_id, :research_billing_qty, :insurance_billing_qty, :effort_billing_qty]
    new_visit_values  = []

    line_item_ids.each do |line_item_id|
      new_visit_values.push [object.id, line_item_id, 0, 0, 0]
    end

    Visit.import new_visit_columns, new_visit_values, { validate: true }
  end

  def line_item_ids
    object.line_items.pluck(:id)
  end
end
