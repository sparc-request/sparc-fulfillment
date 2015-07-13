class ReportsController < ApplicationController

  before_action :find_documentable, only: [:create]

  def new
    @title = reports_params[:title]
    @document = Document.new(title: @title.humanize)
    render @title
  end

  def create
    respond_to do |format|
      format.js do
        @document = Document.new(title: params[:document][:title])

        @documentable.documents.push @document

        ReportJob.perform_later(@document, reports_params.merge(identity_id: current_identity.id))
      end
    end
  end

  private

  def find_documentable
    if params[:documentable_id].present? && params[:documentable_type].present?
      @documentable = params[:documentable_type].constantize.find params[:documentable_id]
    else
      @documentable = current_identity
    end
  end

  def reports_params
    params.
      permit(:format,
              :utf8,
              :title,
              :start_date,
              :end_date,
              :protocol_id,
              :participant_id,
              :documentable_id,
              :documentable_type,
              :protocol_ids => [])
  end
end
