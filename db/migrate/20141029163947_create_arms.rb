class CreateArms < ActiveRecord::Migration
  def change
    create_table :arms do |t|
      t.integer :sparc_id
      t.references :protocol
      t.string :name
      t.integer :visit_count
      t.integer :subject_count

      t.timestamps
    end
  end
end
