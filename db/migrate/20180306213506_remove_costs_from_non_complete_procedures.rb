class RemoveCostsFromNonCompleteProcedures < ActiveRecord::Migration[5.0]
  def change
    Procedure.with_deleted.where.not(service_cost: nil, status: "complete").each do |procedure|
      procedure.service_cost = nil
      procedure.save(validate: false)
    end
  end
end
