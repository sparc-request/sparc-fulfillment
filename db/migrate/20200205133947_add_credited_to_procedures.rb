class AddCreditedToProcedures < ActiveRecord::Migration[5.2]
  def change
  	add_column :procedures, :credited, :boolean
  end
end
