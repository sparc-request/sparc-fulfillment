namespace :data do
  desc "Generate a CSV of Services not associated with any CWF LineItems or Procedures"

  task unused_services_report: :environment do
    HEADER = ["Service ID", "Service Name", "Active?", "CPT Code", "Create Date",
        "Parent", "Parent Type", "Grandparent", "Grandparent Type",
        "Epic Service?"]
    REPORT_PATH = "tmp/unused_services_report.xlsx"
    TABLES_WITH_SERVICE_FOREIGN_KEY = [Fulfillment, Procedure,
      Sparc::Procedure, LineItem, Sparc::LineItem, Sparc::Charge,
      Sparc::ServiceProvider, Sparc::ServiceRelation]

    def format_bool(b)
    	b ? "Yes" : "No"
    end

    used_services = TABLES_WITH_SERVICE_FOREIGN_KEY.map do |table|
      table.where.not(service_id: nil).distinct.pluck(:service_id)
    end.reduce(&:|)

    # Get services not associated with CWF LineItems, not a custom added service
    unused_services = Service.includes(organization: :parent).
      where.not(id: used_services).
      distinct

    inactive_unused_services = []
    unused_services.each do |unused_service|
      if !unused_service.is_available?
        inactive_unused_services << unused_service
      end
    end

    # report rows
    report_data = inactive_unused_services.map do |service|
      [service.id, service.name, format_bool(service.is_available?),
        service.cpt_code, service.created_at, service.organization.name,
        service.organization.type, service.organization.parent.name,
        service.organization.parent.type, format_bool(service.send_to_epic?)]
    end

    # generate spreadsheet
    p                     = Axlsx::Package.new
    wb                    = p.workbook
    default               = wb.styles.add_style alignment: { horizontal: :left }
    primary_header_style  = wb.styles.add_style sz: 12, b: true, bg_color: '0099FF', fg_color: 'FFFFFF', alignment: { horizontal: :left }

    wb.add_worksheet(name: "Unused Services") do |sheet|
      sheet.add_row(HEADER, style: primary_header_style)
      report_data.each do |row|
        sheet.add_row(row, style: default)
      end
    end

    p.serialize(REPORT_PATH)
  end
end
