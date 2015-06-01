class AddPerformerIdToProcedures < ActiveRecord::Migration
  def change
    add_column :procedures, :performer_id, :integer
  end
end
