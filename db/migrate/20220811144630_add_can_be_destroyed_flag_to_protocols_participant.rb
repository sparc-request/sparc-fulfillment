class AddCanBeDestroyedFlagToProtocolsParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols_participants, :can_be_destroyed, :boolean

    ProtocolsParticipant.find_each do |p|
      p.update_attribute(:can_be_destroyed, true) if !p.procedures.touched.any?
    end
  end
end
