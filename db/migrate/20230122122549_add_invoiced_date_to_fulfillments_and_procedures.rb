class AddInvoicedDateToFulfillmentsAndProcedures < ActiveRecord::Migration[5.2]
  def change
   tables = [:fulfillments, :procedures]

    tables.each do |table_name|
      add_column table_name, :invoiced_date, :datetime, after: :invoiced
    end
  end
end
