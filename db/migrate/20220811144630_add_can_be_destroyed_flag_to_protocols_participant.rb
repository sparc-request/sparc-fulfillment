class AddCanBeDestroyedFlagToProtocolsParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols_participants, :can_be_destroyed, :boolean

    ProtocolsParticipant.find_each do |p|
      if p.procedures.touched.any?
        p.update_attribute(:can_be_destroyed, false)
      else
        p.update_attribute(:can_be_destroyed, true)
      end
    end
  end
end
