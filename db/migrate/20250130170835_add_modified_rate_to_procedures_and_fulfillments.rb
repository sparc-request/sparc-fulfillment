class AddModifiedRateToProceduresAndFulfillments < ActiveRecord::Migration[5.2]
  def change
    add_column :procedures, :modified_rate, :boolean, default: false, null: false
    add_column :fulfillments, :modified_rate, :boolean, default: false, null: false
  end
end
