class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.integer :sparc_id
      t.text :title
      t.string :short_title
      t.string :sponsor_name
      t.string :udac_project_number
      t.integer :requester_id
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :recruitment_start_date
      t.datetime :recruitment_end_date

      t.timestamps
    end
  end
end
