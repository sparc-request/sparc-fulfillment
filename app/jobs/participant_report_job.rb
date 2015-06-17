class ParticipantReportJob < ActiveJob::Base
  queue_as :default

  def perform(report_id, participant_id)
    CSV.open("tmp/participant_report.csv", "wb") do |csv|
      participant = Participant.find(participant_id)
      protocol = participant.protocol

      csv << ["Protocol:", participant.protocol.short_title_with_sparc_id]
      csv << ["Protocol PI Name:", protocol.pi ? "#{protocol.pi.full_name} (#{protocol.pi.email})" : nil]
      csv << ["Participant Name:", participant.full_name, "Participant ID:", participant.label]
      csv << [""]
      csv << [""]
    end

    report = Report.find(report_id)

    if report.create_document(doc: File.open("tmp/participant_report.csv"))
      report.status = "Completed"
      report.save
    end
    FayeJob.enqueue(report)
  end
end
