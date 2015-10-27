class ReportJob < ActiveJob::Base

  queue_as :reports

  before_enqueue do
    find_or_create_document_root_path
  end

  def perform(document, params)
    document_name = document.title
    report        = document.report_type.classify.constantize.new(params)

    report.generate(document)

    FayeJob.perform_later document
  end

  rescue_from(StandardError) do |error|
    arguments.first.update_attributes state: 'Error'
    FayeJob.perform_later arguments.first
  end

  after_perform do |job|
    job.
      arguments.
      first.
      update_attributes state: 'Completed'

    document = job.arguments.first

    case document.documentable_type
      when 'Protocol'
        protocol = Protocol.find(job.arguments.last[:documentable_id])
        protocol.document_counter_updated = true
        protocol.update_attributes(unaccessed_documents_count: (protocol.unaccessed_documents_count + 1))
      when 'Identity'
        find_identity(job).update_counter(:unaccessed_documents, 1)
    end
  end

  private

  def find_identity(job)
    @identity ||= Identity.find job.arguments.last[:identity_id]
  end

  def find_or_create_document_root_path
    unless Dir.exists? ENV.fetch('DOCUMENTS_FOLDER')
      Dir.mkdir ENV.fetch('DOCUMENTS_FOLDER')
    end
  end
end
