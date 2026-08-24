class CreateTimeTrackings < ActiveRecord::Migration[7.2]
  def change
    create_table :time_trackings do |t|
      t.integer :protocol_id
      t.integer :sub_service_request_id
      t.integer :line_item_id
      t.integer :component_id
      t.integer :identity_id
      t.date :date
      t.datetime :started_at
      t.datetime :ended_at
      t.decimal :quantity
      t.string :notes
      t.string :text
      t.string :status

      t.timestamps
    end
  end
end
