class RemoveServiceCostFromIncompleteProcedures < ActiveRecord::Migration
  def change
    Procedure.where.not(status: "complete").update_all(service_cost: nil)
  end
end
