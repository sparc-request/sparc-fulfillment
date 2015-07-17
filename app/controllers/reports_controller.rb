class ReportsController < ApplicationController

  before_action :find_documentable, only: [:create]

  def new
    @report_type = reports_params[:title]
    @title = @report_type.titleize
  end

  def create
    @document = Document.new(title: params[:title].humanize)

    @document.errors.add(:title, "can't be blank") if params[:title].blank?
    @document.errors.add(:start_date, "can't be blank") if params[:start_date].blank?
    @document.errors.add(:end_date, "can't be blank") if params[:end_date].blank?
    @document.errors.add(:protocols, "must be selected") if params[:protocol_id].blank?

    if @document.errors.empty?
      @documentable.documents.push @document

      ReportJob.perform_later(@document, reports_params.merge(identity_id: current_identity.id))
    else
      @errors = @document.errors
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
