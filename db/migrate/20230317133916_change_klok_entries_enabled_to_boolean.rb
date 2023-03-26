class ChangeKlokEntriesEnabledToBoolean < ActiveRecord::Migration[5.2]
  def change
    change_column :klok_entries, :enabled, :boolean
  end
end
