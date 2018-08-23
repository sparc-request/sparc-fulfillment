class AddFundingSourceToFulfillments < ActiveRecord::Migration[5.0]
  def change
    add_column :fulfillments, :funding_source, :string, after: :quantity
  end
end
