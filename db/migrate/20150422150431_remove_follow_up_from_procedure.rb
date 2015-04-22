class RemoveFollowUpFromProcedure < ActiveRecord::Migration
  def change
    remove_column :procedures, :follow_up_date
  end
end
