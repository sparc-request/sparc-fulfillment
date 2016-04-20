class RemoveServiceCostFromIncompleteProcedures < ActiveRecord::Migration
  def change
    Procedure.where("service_cost != ? AND status != ?", false, 'complete').find_each do |procedure|
      procedure.update_attribute(:service_cost, nil)
    end
  end
end
