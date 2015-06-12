class ParticipantReport < Report

  require 'csv'

  def generate(document)
    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")
    participant = Participant.find(@params[:participant_id])
    protocol    = participant.protocol

    CSV.open(document.path, "wb") do |csv|
      csv << ["Protocol:", participant.protocol.short_title_with_sparc_id]
      csv << ["Protocol PI Name:", protocol.pi ? "#{protocol.pi.full_name} (#{protocol.pi.email})" : nil]
      csv << ["Participant Name:", participant.full_name, "Participant ID:", participant.label]
      csv << [""]
      csv << [""]
    end
  end
end
