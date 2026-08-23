class CreateTimeTrackingProtocols < ActiveRecord::Migration[7.2]
  def change
    create_table :time_tracking_protocols do |t|
      t.integer :identity_id
      t.integer :protocol_id

      t.timestamps
    end
  end
end
