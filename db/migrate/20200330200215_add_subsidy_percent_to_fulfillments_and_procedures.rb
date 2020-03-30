class AddSubsidyPercentToFulfillmentsAndProcedures < ActiveRecord::Migration[5.2]
  def change
    add_column :fulfillments, :percent_subsidy, :float
    add_column :procedures, :percent_subsidy, :float
  end
end
