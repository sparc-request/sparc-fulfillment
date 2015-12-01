class ReportsController < ApplicationController

  before_action :find_documentable, only: [:create]

  def new
    @report = report_params[:kind].classify.constantize.new
  end

  def create
    @document = Document.new document_params

    if @documentable.documents.push @document
      ReportJob.perform_later @document, @report_params
    end
  end

  private

  def document_params
    {
      start_date: report_params[:start_date],
      end_date:   report_params[:end_date],
      kind:       report_params[:kind],
      title:      report_params[:title]
    }
  end

  def find_documentable
    if params[:documentable_id].present? && params[:documentable_type].present?
      @documentable = params[:documentable_type].constantize.find params[:documentable_id]
    else
      @documentable = current_identity
    end
  end

  def report_params
    @report_params ||= params.
      require(:report).
      permit( :kind,
              :title,
              :start_date,
              :end_date,
              :protocol_id,
              :participant_id,
              :documentable_id,
              :documentable_type,
              protocol_ids: []).
        merge(identity_id: current_identity.id)
  end
end
