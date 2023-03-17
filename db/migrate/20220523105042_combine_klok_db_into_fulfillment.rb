class CombineKlokDbIntoFulfillment < ActiveRecord::Migration[5.2]
  def change
    create_table :klok_entries, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.column :project_id, :integer, null: false
      t.column :resource_id, :integer
      t.column :rate, :integer
      t.column :date, :datetime
      t.column :start_time_stamp_formatted, :string, limit: 255
      t.column :start_time_stamp, :datetime
      t.primary_key :entry_id, :integer, null: false
      t.column :duration, :integer
      t.column :submission_id, :integer
      t.column :device_id, :integer
      t.column :comments, :text
      t.column :end_time_stamp_formatted, :string, limit: 255
      t.column :end_time_stamp, :datetime
      t.column :rollup_to, :integer
      t.column :enabled, :integer
      t.column :created_at, :datetime
    end

    create_table :klok_people, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.primary_key :resource_id, :integer, null: false
      t.column :name, :string, limit: 255
      t.column :username, :string, limit: 255
      t.column :created_at, :datetime
    end

    create_table :klok_projects, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.primary_key :project_id, :integer, null: false
      t.column :contact_email, :string, limit: 255
      t.column :path, :integer
      t.column :code, :string, limit: 255
      t.column :contact_phone, :string, limit: 255
      t.column :updated_at, :datetime
      t.column :project_type, :string, limit: 255
      t.column :name, :string, limit: 255
      t.column :parent_id, :integer
      t.column :created_at, :datetime
      t.column :contact_name, :string, limit: 255
      t.column :rollup_to, :integer
    end
  end
end
