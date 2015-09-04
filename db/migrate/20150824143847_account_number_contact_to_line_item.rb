class AccountNumberContactToLineItem < ActiveRecord::Migration
  def change
    remove_column :fulfillments, :account_number, :string
    add_column :line_items, :account_number, :string
    add_column :line_items, :contact_name, :string
  end
end
