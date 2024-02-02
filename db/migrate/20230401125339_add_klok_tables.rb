class AddKlokTables < ActiveRecord::Migration[5.2]
  def change
    create_table :klok_entries, { id: false } do |t|
      t.timestamp :created_at
      t.integer :project_id, null: false
      t.integer :resource_id
      t.integer :rate
      t.date :date
      t.string :start_time_stamp_formatted
      t.timestamp :start_time_stamp
      t.integer :entry_id, null: false
      t.integer :duration
      t.integer :submission_id
      t.integer :device_id
      t.text :comments
      t.string :end_time_stamp_formatted
      t.timestamp :end_time_stamp
      t.integer :rollup_to
      t.boolean :enabled, default: 0
    end

    create_table :klok_people, { id: false } do |t|
      t.primary_key :resource_id
      t.string :name
      t.string :username
      t.timestamp :created_at
    end

    create_table :klok_projects, { id: false } do |t|
      t.string :contact_email
      t.primary_key :project_id
      t.integer :path
      t.string :code
      t.string :contact_phone
      t.timestamp :updated_at
      t.string :project_type
      t.string :name
      t.integer :parent_id
      t.timestamp :created_at
      t.string :contact_name
      t.integer :rollup_to
    end

  end
end
