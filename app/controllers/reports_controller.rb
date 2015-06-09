class ReportsController < ApplicationController

  respond_to :json, :html

  def index
    respond_to do |format|
      format.html { render }
      format.json do
        @reports = Report.where(identity: current_identity)
        render
      end
    end
  end

  def new_billing_report
     @protocols = current_identity.protocols
  end

  def new_auditing_report
     @protocols = current_identity.protocols
  end

  def new_participant_report
    protocol_ids = current_identity.protocols.map(&:id)
    @participants.where(protocol_id: protocol_ids)
  end

  def new_project_summary_report
     @protocols = current_identity.protocols
  end

  def create_billing_report
    @report = current_identity.reports.new(name: "Billing Report", status: "Pending")
    date_validation(params[:start_date], params[:end_date])

    unless @report.errors.any?
      @report.save
      start_date = Time.strptime(params[:start_date], "%m-%d-%Y").to_date.to_s
      end_date = Time.strptime(params[:end_date], "%m-%d-%Y").to_date.to_s

      BillingReportJob.perform_later(@report.id, start_date, end_date, params[:protocol_ids])
    end
    render :create_report
  end

  def create_auditing_report
    @report = current_identity.reports.new(name: "Auditing Report", status: "Pending")
    date_validation(params[:start_date], params[:end_date])

    unless @report.errors.any?
      @report.save
      start_date = Time.strptime(params[:start_date], "%m-%d-%Y").to_date.to_s
      end_date = Time.strptime(params[:end_date], "%m-%d-%Y").to_date.to_s

      AuditingReportJob.perform_later(@report.id, start_date, end_date, params[:protocol_ids])
    end
    render :create_report
  end

  def create_participant_report
    @report = current_identity.reports.new(name: "Participant Report", status: "Pending")

    unless @report.errors.any?
      @report.save
      ParticipantReportJob.perform_later(@report.id, params[:participant_id])
    end
    render :create_report
  end

  def create_project_summary_report
    @report = current_identity.reports.new(name: "Project Summary Report", status: "Pending")
    date_validation(params[:start_date], params[:end_date])

    unless @report.errors.any?
      @report.save
      start_date = Time.strptime(params[:start_date], "%m-%d-%Y").to_date.to_s
      end_date = Time.strptime(params[:end_date], "%m-%d-%Y").to_date.to_s

      ProjectSummaryReportJob.perform_later(@report.id, start_date, end_date, params[:protocol_id])
    end
    render :create_report
  end

  private

  def date_validation(start_date, end_date)
    if start_date == ""
      @report.errors.add(:start_date, "Cannot be blank")
    end
    if end_date == ""
      @report.errors.add(:end_date, "Cannot be blank")
    end
  end
end
