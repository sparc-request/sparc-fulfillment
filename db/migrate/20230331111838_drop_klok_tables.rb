class DropKlokTables < ActiveRecord::Migration[5.2]
  def up
    drop_table :klok_entries
    drop_table :klok_people
    drop_table :klok_projects
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
