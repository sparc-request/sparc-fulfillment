class AddIncompleteDateToProcedures < ActiveRecord::Migration
  def change
    add_column :procedures, :incompleted_date, :datetime
  end
end
