# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
