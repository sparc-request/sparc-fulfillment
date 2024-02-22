namespace :update_deletable do
  desc "Update the deletable flag for all protocols_participants"
  task protocols_participants: :environment do
    total_records = ProtocolsParticipant.count
    updated_records = 0

    ProtocolsParticipant.find_each do |pp|
      begin
        if pp.update!(deletable: !pp.procedures.exists?(status: ['follow_up', 'incomplete', 'complete']))
          updated_records += 1
        end
      rescue => e
        puts "Error updating deletable flag for ProtocolsParticipant #{pp.id}: #{e.message}"
      end
    end

    puts "Updated #{updated_records} of #{total_records} ProtocolsParticipants"
  end
end
