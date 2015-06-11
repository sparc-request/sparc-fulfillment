class RemoveReasonColumnFromProcedures < ActiveRecord::Migration
  def change
    remove_column :procedures, :reason
  end
end
