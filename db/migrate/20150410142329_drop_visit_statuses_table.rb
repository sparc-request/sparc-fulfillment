class DropVisitStatusesTable < ActiveRecord::Migration
  def change
    drop_table :visit_statuses
  end
end
