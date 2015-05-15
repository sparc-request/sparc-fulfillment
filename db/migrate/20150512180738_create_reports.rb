class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.string :status
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_column :reports, :deleted_at, :datetime
  end
end
