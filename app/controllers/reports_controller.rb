class ReportsController < ApplicationController

  before_action :find_documentable, only: [:create]
  before_action :find_report_type, only: [:new, :create]

  def new
    @title = @report_type.titleize
  end

  def create
    @document = Document.new(title: reports_params[:title].humanize, report_type: @report_type)

    validate_report_form
    if @document.errors.empty?
      @documentable.documents.push @document

      ReportJob.perform_later(@document, reports_params.merge(identity_id: current_identity.id))
    else
      @errors = @document.errors
    end
  end

  private

  def validate_report_form
    @report_type.classify.constantize::VALIDATES_PRESENCE_OF.each do |validates|
      @document.errors.add(validates, "must be present") if reports_params[validates].blank?
    end
  end

  def find_documentable
    if params[:documentable_id].present? && params[:documentable_type].present?
      @documentable = params[:documentable_type].constantize.find params[:documentable_id]
    else
      @documentable = current_identity
    end
  end

  def find_report_type
    @report_type = reports_params[:report_type]
  end

  def reports_params
    params.require(:report_type) # raises error if report_type not present

    params.permit(:format,
              :utf8,
              :report_type,
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
