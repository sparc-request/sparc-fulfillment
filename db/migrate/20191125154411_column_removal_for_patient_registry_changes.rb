class ColumnRemovalForPatientRegistryChanges < ActiveRecord::Migration[5.2]
  def change
  	remove_column :participants, :sparc_id
    remove_column :participants, :protocol_id
    remove_column :participants, :arm_id
    remove_column :participants, :status

    remove_column :appointments, :participant_id
  end
end