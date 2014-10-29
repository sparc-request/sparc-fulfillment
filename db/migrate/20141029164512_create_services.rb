class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :sparc_id
      t.decimal :cost
      t.string :name
      t.string :appreviation
      t.text :description

      t.timestamps
    end
  end
end
