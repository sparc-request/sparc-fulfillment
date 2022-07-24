class SetDeletableColumnValues < ActiveRecord::Migration[5.2]
  def change
    # After creating new 'deletable' column in previous migration, this method will backfill existing 'protocols_participants' records with new 'deletable' colulmn value
    ProtocolsParticipant.all.each do |p|
      if p.procedures.where.not(status: 'unstarted').empty?
        p.update_attribute(:deletable, true)
        p.save
      else
        p.update_attribute(:deletable, false)
        p.save
      end
    end
  end
end
