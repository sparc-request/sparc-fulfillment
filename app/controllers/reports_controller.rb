class ReportsController < ApplicationController

  before_action :find_documentable, only: [:create]
  before_action :find_report_type, only: [:new, :create]

  def new
    @title = @report_type.titleize
    @organizations = IdentityOrganizations.new(current_identity.id).fulfillment_organizations_with_protocols
    @grouped_options = InvoiceReportGroupedOptions.new(@organizations).collect_grouped_options
  end

  def create
    @document = Document.new(title: reports_params[:title].humanize, report_type: @report_type)
    
    @report = @report_type.classify.constantize.new(reports_params)
    @errors = @report.errors

    if @report.valid?
      @reports_params = reports_params
      @documentable.documents.push @document
      ReportJob.perform_later(@document, reports_params)
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

  def find_report_type
    @report_type = reports_params[:report_type]
  end

  def reports_params
    params.require(:report_type) # raises error if report_type not present
    params.except!(:organizations)
    params.permit(:format,
              :utf8,
              :report_type,
              :title,
              :start_date,
              :end_date,
              :time_zone,
              :protocol_id,
              :sort_by,
              :sort_order,
              :participant_id,
              :documentable_id,
              :documentable_type,
              :protocol_ids => []).merge(identity_id: current_identity.id)
  end
end
