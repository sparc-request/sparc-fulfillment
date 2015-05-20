class CreateReports < ActiveRecord::Migration
  def up
    create_table :reports do |t|
      t.string :name
      t.string :status
      t.references :user, index: true

      t.timestamps null: false
    end
    add_column :reports, :deleted_at, :datetime
  end

  def down
    drop_table :reports
  end
end
