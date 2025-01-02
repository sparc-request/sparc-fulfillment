# Copyright © 2011-2025 MUSC Foundation for Research Development~
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

module ReportsSharedMethods
  extend ActiveSupport::Concern

  # A protocol with subsidy, format protocol_id column with an 's'
  # A protocol without subsidy, format protocol_id column without an 's'
  def format_protocol_id_column(protocol)
    protocol.subsidies.any? ? protocol.sparc_id.to_s + 's' : protocol.sparc_id
  end

  def display_pppv_modified_rate_column(procedure)
    admin_rate = procedure.send(:admin_rate)
    admin_rate && admin_rate.created_at.to_date <= procedure.completed_date.to_date || procedure.send(:old_admin_rates) && procedure.send(:check_old_admin_rates, procedure.completed_date) ? "Yes" : "No"
  end

  def display_otf_modified_rate_column(fulfillment)
    line_item = fulfillment.line_item
    line_item.send(:current_admin_rate) && line_item.send(:current_admin_rate_applicable?, fulfillment.fulfilled_at) || line_item.send(:old_admin_rates) && line_item.send(:applicable_old_admin_rate, fulfillment.fulfilled_at) ? "Yes" : "No"
  end

  def display_subsidy_percent(object)
    object.percent_subsidy.nil? ? "N/A" : "#{object.percent_subsidy * 100}%"
  end

  def fiscal_year_month_display(completed_date, fiscal_start_month = 7)
    month_number = ((completed_date.month - fiscal_start_month) % 12) + 1
    abbreviated_month = completed_date.strftime("%b")
    sprintf("%02d-%s", month_number, abbreviated_month)
  end

  def fiscal_year_display(completed_date, fiscal_start_month = 7)
    fiscal_year = completed_date.month >= fiscal_start_month ? completed_date.year : completed_date.year - 1
    sprintf("%04d", fiscal_year)
  end

  def get_previous_funding_source(protocol)
    audit = Sparc::Audit.where(
      auditable_type: "Protocol",
      auditable_id: protocol.sparc_id,
      action: "update",
      )
      .order(created_at: :desc)
      .find { |a| YAML.load(a.audited_changes)["funding_source"] }
    previous_funding_info = audit ? YAML.load(audit.audited_changes)["funding_source"] : []
    {
      previous_funding_source: previous_funding_info.first&.humanize,
      change_date: audit ?  format_date(audit.created_at) : nil
    }
  end
end
