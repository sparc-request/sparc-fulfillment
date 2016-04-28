class RemoveServiceCostFromIncompleteProcedures < ActiveRecord::Migration
  def change
    Procedure.where.not(service_cost: false, status: "complete").find_each do |procedure|
      procedure.update_attribute(:service_cost, nil)
    end
  end
end
