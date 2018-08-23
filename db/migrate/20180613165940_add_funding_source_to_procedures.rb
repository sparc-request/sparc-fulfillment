class AddFundingSourceToProcedures < ActiveRecord::Migration[5.0]
  def change
    add_column :procedures, :funding_source, :string
  end
end
