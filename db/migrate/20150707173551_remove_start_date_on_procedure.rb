class RemoveStartDateOnProcedure < ActiveRecord::Migration
  def change
    remove_column :procedures, :start_date, :datetime
  end
end
