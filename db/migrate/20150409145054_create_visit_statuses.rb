class CreateVisitStatuses < ActiveRecord::Migration
  def change
    create_table :visit_statuses do |t|
      t.string :status
      t.timestamps
      t.timestamp :deleted_at
    end
  end
end
