class DropUsersTable < ActiveRecord::Migration
  def up
    drop_table :users
  end

  def down
    create_table "users", force: :cascade do |t|
      t.string   "email",                  limit: 255, default: "",                           null: false
      t.string   "encrypted_password",     limit: 255, default: "",                           null: false
      t.string   "reset_password_token",   limit: 255
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          limit: 4,   default: 0,                            null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip",     limit: 255
      t.string   "last_sign_in_ip",        limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "first_name",             limit: 255
      t.string   "last_name",              limit: 255
      t.string   "time_zone",              limit: 255, default: "Eastern Time (US & Canada)"
      t.integer  "tasks_count",            limit: 4,   default: 0
    end
  end
end
