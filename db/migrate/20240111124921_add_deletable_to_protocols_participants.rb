class AddDeletableToProtocolsParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols_participants, :deletable, :boolean, default: true
  end
end
