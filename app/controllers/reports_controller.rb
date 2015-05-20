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

  def billing_report
    @report = current_identity.reports.new(name: "Billing Report", status: "Pending")
    if params[:start_date] == ""
      @report.errors.add(:start_date, "Cannot be blank")
    end
    if params[:end_date] == ""
      @report.errors.add(:end_date, "Cannot be blank")
    end

    unless @report.errors.any?
      @report.save
      start_date = Time.strptime(params[:start_date], "%m-%d-%Y").to_date.to_s
      end_date = Time.strptime(params[:end_date], "%m-%d-%Y").to_date.to_s

      BillingReportJob.perform_later(@report.id, start_date, end_date, params[:protocol_ids])
    end
  end

  def new_billing_report
    @report = Report.new()
  end
end
