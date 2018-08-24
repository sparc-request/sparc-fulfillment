class AddInvoicedToProceduresAndFulfillments < ActiveRecord::Migration[5.0]
  def change
    add_column :procedures, :invoiced, :boolean
    add_column :fulfillments, :invoiced, :boolean
  end
end
