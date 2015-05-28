class AddPerformedByToProcedures < ActiveRecord::Migration
  def change
    add_column :procedures, :performed_by, :integer
  end
end
