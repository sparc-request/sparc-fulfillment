# lib/tasks/finance_billing_report.rake

namespace :report do
  desc "Generate finance billing report"
  task finance_billing_report: :environment do
    require 'csv'

    params = {
      title: 'Finance Billing Report',
      start_date: "07/01/2024",
      end_date: "10/31/2024",
      sort_by: 'Protocol ID',
      sort_order: 'ASC',
      organizations: Organization.all.pluck(:id),
      protocols: Protocol.all.pluck(:id),
      services: Service.all.pluck(:id),
      include_notes: 'true',
      include_invoiced: 'true'
    }

    document_path = Rails.root.join('tmp', 'finance_billing_report.csv')
    document = Document.create(
      content_type: 'text/csv',
      original_filename: "finance_billing_report.csv"
    )

    report = FinanceBillingReport.new(params)
    report.generate(document_path, params)

    puts "Finance Billing Report generated at #{document_path}"
  end
end
