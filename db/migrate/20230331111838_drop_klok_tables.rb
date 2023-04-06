class DropKlokTables < ActiveRecord::Migration[5.2]
  def up
    drop_table :klok_entries, if_exists: true
    drop_table :klok_people, if_exists: true
    drop_table :klok_projects, if_exists: true
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
