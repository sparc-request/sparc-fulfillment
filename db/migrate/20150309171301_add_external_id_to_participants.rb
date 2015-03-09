class AddExternalIdToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :external_id, :string
  end
end
