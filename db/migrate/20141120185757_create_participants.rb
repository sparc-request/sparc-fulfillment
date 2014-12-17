class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.references :protocol
      t.references :arm
      t.string :first_name
      t.string :last_name
      t.integer :mrn
      t.string :status
      t.date :date_of_birth
      t.string :gender
      t.string :ethnicity
      t.string :race
      t.string :address
      t.string :phone
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
