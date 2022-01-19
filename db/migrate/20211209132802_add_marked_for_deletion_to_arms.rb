class AddMarkedForDeletionToArms < ActiveRecord::Migration[5.2]
  def change
    add_column :arms, :marked_for_deletion, :boolean, default: false
  end
end
