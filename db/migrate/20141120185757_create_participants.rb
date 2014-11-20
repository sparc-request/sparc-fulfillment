class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.references :protocol
      t.string :first_name
      t.string :last_name
      t.integer :mrn
      t.string :status
      t.datetime :date_of_birth
      t.string :gender
      t.string :ethnicity

      t.timestamps
    end
  end
end
