class CreateVisitGroups < ActiveRecord::Migration
  def change
    create_table :visit_groups do |t|
      t.integer :sparc_id
      t.references :arm, index: true
      t.integer :position
      t.string :name
      t.integer :day
      t.integer :window_before
      t.integer :window_after

      t.timestamps
    end
  end
end
