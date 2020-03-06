class MoveExternalIdAndRecruitmentSourceFromParticipantsToProtocolsParticipant < ActiveRecord::Migration[5.2]
  def change
  	add_column :protocols_participants, :external_id, :string
  	add_column :protocols_participants, :recruitment_source, :string

  	progress_bar = ProgressBar.new(Participant.count)
    Participant.all.each do |participant|
      ProtocolsParticipant.where(participant_id: participant.id).update_all(external_id: participant.external_id, recruitment_source: participant.recruitment_source)
      progress_bar.increment!
    end

    remove_column :participants, :external_id, :string
    remove_column :participants, :recruitment_source, :string
  end
end