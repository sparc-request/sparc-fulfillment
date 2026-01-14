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
    has_admin_rate = false
    admin_rate = procedure.send(:admin_rate)
    if admin_rate && admin_rate.created_at.to_date <= procedure.completed_date.to_date
      has_admin_rate = true

    else
      old_rates = procedure.send(:old_admin_rates)
      if old_rates.present?
        latest_old_rate_not_reset = old_rates
          .where(cost_reset: false)
          .where("DATE(date_of_change) <= ?", procedure.completed_date)
          .order(date_of_change: :desc).first
        if latest_old_rate_not_reset && procedure.service_cost == latest_old_rate_not_reset.admin_cost
          has_admin_rate = true
        end
      end
    end

    reg_rate_with_funding = procedure.service.cost(procedure.funding_source, procedure.completed_date).to_i
    reg_rate_without_funding = procedure.service.cost(nil, procedure.completed_date).to_i
    if has_admin_rate && (reg_rate_with_funding != procedure.service_cost && reg_rate_without_funding != procedure.service_cost)
      "Yes"
    else
      "No"
    end
  end

  def display_otf_modified_rate_column(fulfillment)
    line_item = fulfillment.line_item
    has_admin_rate = false
    if line_item.send(:current_admin_rate) && line_item.send(:current_admin_rate_applicable?, fulfillment.fulfilled_at)
      has_admin_rate = true

    else
      old_rates = line_item.send(:old_admin_rates)
      if old_rates.present?
        latest_old_rate_not_reset = old_rates
        .where(cost_reset: false)
        .where("DATE(date_of_change) <= ?", fulfillment.fulfilled_at)
        .order(date_of_change: :desc).first
        if latest_old_rate_not_reset && fulfillment.service_cost == latest_old_rate_not_reset.admin_cost
          has_admin_rate = true
        end
      end
    end

    reg_rate_with_funding = line_item.service.cost(line_item.protocol.sparc_funding_source, fulfillment.fulfilled_at).to_i
    reg_rate_without_funding = line_item.service.cost(nil, fulfillment.fulfilled_at).to_i
    if has_admin_rate && (reg_rate_with_funding != fulfillment.service_cost && reg_rate_without_funding != fulfillment.service_cost)
      "Yes"
    elsif has_admin_rate && (reg_rate_with_funding == fulfillment.service_cost || reg_rate_without_funding == fulfillment.service_cost)
      "No"
    else
      "No"
    end
  end

  def display_subsidy_percent(object)
    object.percent_subsidy.nil? ? "N/A" : "#{object.percent_subsidy * 100}%"
  end

  def fiscal_year_display(completed_date, fiscal_start_month = 7)
    fiscal_year = completed_date.month >= fiscal_start_month ? completed_date.year + 1 : completed_date.year
    sprintf("FY%02d", fiscal_year % 100)
  end

  def get_previous_funding_source(protocol)
    audit = Sparc::Audit.where(
      auditable_type: "Protocol",
      auditable_id: protocol.sparc_id,
      action: "update",
      )
      .order(created_at: :desc)
      .find { |a| YAML.load(a.audited_changes, aliases: true)["funding_source"] }
    previous_funding_info = audit ? YAML.load(audit.audited_changes)["funding_source"] : []
    {
      previous_funding_source: previous_funding_info.first&.humanize,
      change_date: audit ?  format_date(audit.created_at) : nil
    }
  end
end
