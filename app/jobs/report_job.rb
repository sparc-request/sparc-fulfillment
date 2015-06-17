class ReportJob < ActiveJob::Base

  require 'csv'

  queue_as :reports

  def perform(document, params)
    document_name = params[:title]
    @report       = params[:title].classify.constantize.new(params)

    find_or_create_document_root_path

    @report.generate(document)

    document.update_attributes state: 'Completed'

    FayeJob.enqueue document
  end

  private

  def find_or_create_document_root_path
    unless Dir.exists? ENV.fetch('DOCUMENT_ROOT')
      Dir.mkdir ENV.fetch('DOCUMENT_ROOT')
    end
  end
end
