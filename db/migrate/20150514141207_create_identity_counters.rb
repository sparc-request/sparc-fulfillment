class CreateIdentityCounters < ActiveRecord::Migration
  def change
    create_table :identity_counters do |t|
      t.references :identity, index: true
      t.integer :tasks_count, default: 0

      t.timestamps null: false
    end
  end
end
