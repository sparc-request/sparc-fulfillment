class ReportJob < ActiveJob::Base

  queue_as :reports

  before_enqueue do
    find_or_create_document_root_path
  end

  before_perform do |job|
    job.
      arguments.
      first.
      update_attributes state: 'Processing'
  end

  def perform(document, params)
    document_name = params[:title]
    report        = params[:title].classify.constantize.new(params)

    report.generate(document)

    FayeJob.perform_later document
  end

  after_perform do |job|
    job.
      arguments.
      first.
      update_attributes state: 'Completed'

    job.
      arguments.
      first.
      documentable.
      update_counter(:unaccessed_documents, 1)
  end

  private

  def find_or_create_document_root_path
    unless Dir.exists? ENV.fetch('DOCUMENT_ROOT')
      Dir.mkdir ENV.fetch('DOCUMENT_ROOT')
    end
  end
end
