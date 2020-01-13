class AddCreditedToFulfillments < ActiveRecord::Migration[5.2]
  def change
  	add_column :fulfillments, :credited, :boolean
  end
end
