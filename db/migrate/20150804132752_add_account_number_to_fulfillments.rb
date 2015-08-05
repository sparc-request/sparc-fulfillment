class AddAccountNumberToFulfillments < ActiveRecord::Migration
  def change
    add_column :fulfillments, :account_number, :string
  end
end
