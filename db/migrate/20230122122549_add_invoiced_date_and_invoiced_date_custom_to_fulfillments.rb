class AddInvoicedDateAndInvoicedDateCustomToFulfillments < ActiveRecord::Migration[5.2]
  def change
    add_column :fulfillments, :invoiced_date, :datetime, after: :invoiced
    add_column :fulfillments, :invoiced_date_custom, :datetime, after: :invoiced_date
  end
end
