class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :sparc_id
      t.string :action
      t.string :callback_url

      t.timestamps
    end

    add_index "notifications", ["sparc_id"], name: "index_notifications_on_sparc_id", using: :btree
  end
end
