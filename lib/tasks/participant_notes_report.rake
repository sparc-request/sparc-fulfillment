
namespace :data do
  task participant_notes_report: :environment do
    def create_csv(records, type)
      CSV.open("/Users/iee/Desktop/participant_#{type}.csv", 'w', headers: true) do |csv|
      csv << ["#{type}"]
        header = []
        header << "Participant ID"
        header << "First Name"
        header << "Last Name"
        header << "Fulfillment Study ID"
        header << "SPARC Study ID"
        header << "Study Arms"
        header << "Participant's Study Arm"
        header << "Participant Note"
        header << "Note ID"
        header << "Note Writer First Name"
        header << "Note Writer Last Name"
        header << "Date Note Logged"
        header << "Date Note Updated"
        header << "Participant Study Status"
        header << "External ID"
        header << "Recruitment Source"
        header << "Date Added to Study"
        header << "Date Updtated on Study"
        header << "Service Req"
        header << "Service Req Status"
        header << "SPARC Study Sub Service Request ID"
        header << "Organization"
        header << "Arm ID"
        header << "Visits on Arm"
        header << "Date Arm Last Updated"
        csv << header
        records.each do |participant|
          participant.protocols_participants.each do |pp|
            pp.protocol.sub_service_requests.each do |ssr|
              participant.notes.each do |note|
                data = []
                data << participant.id
                data << participant.first_name
                data << participant.last_name
                data << pp.protocol_id
                data << pp.protocol.sparc_protocol.id
                arms = []
                pp.protocol.arms.each do |arm|
                  arms << arm.name
                end
                data << arms
                data << pp.try(:arm).try(:name) || "No Arm Connected with this protocols_participant"
                data << note.comment
                data << note.id
                data << note.identity.first_name
                data << note.identity.last_name
                data << note.created_at
                data << note.updated_at
                data << pp.status
                data << pp.external_id
                data << pp.recruitment_source
                data << pp.created_at
                data << pp.updated_at
                data << ssr.service_request.id
                data << ssr.service_request.status
                data << ssr.id
                data << ssr.organization.name
                data << pp.try(:arm).try(:id) || "No Arm Connected with this protocols_participant"
                data << pp.try(:arm).try(:visit_groups).try(:count) || "No Arm Connected with this protocols_participant"
                data << pp.try(:arm).try(:updated_at) || "No Arm Connected with this protocols_participant"
                csv << data
              end
            end
          end
        end
      end
    end

    puts "Retrieving participants..."
    @participants = Participant.all
    @participants_protocols_type = {single_protocol: [], multi_protocol: []}

    puts "Participants retrieved.  Now sorting participants."
    @participants.each do |participant|
      if participant.protocols.count > 1
        @participants_protocols_type[:multi_protocol] << participant
      else 
        @participants_protocols_type[:single_protocol] << participant
      end
    end

    puts "Participant sorting complete."

    puts "Now building csv for multi-protocol participants..."
    create_csv(@participants_protocols_type[:multi_protocol], "multi_protocol")
    puts "Multi-protocol participant csv built and saved."

    puts "Now building csv for single-protocol participants..."
    create_csv(@participants_protocols_type[:single_protocol], "single_protocol")
    puts "Single-protocol participant csv built and saved."

    puts "All tasks complete.  Shutting down."
  end
end


