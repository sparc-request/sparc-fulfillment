class ReportsController < ApplicationController

  def new
    @title = reports_params[:title]

    render @title
  end

  def create
    respond_to do |format|
      format.js do
        @document = Document.new(title: reports_params[:title].humanize)

        current_identity.documents.push @document

        ReportJob.perform_later(@document, reports_params)
      end
    end
  end

  private

  def reports_params
    params.
      permit(:format,
              :utf8,
              :title,
              :start_date,
              :end_date,
              :protocol_ids,
              :protocol_id,
              :participant_id)
  end
end
