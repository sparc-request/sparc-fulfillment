# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

class ReportsController < ApplicationController
  before_action :find_documentable, only: [:create]
  before_action :find_report_type, only: [:new, :create]

  def new
    @title = @report_type.titleize
    @organizations = IdentityOrganizations.new(current_identity.id).fulfillment_organizations_with_protocols
    @grouped_options = InvoiceReportGroupedOptions.new(@organizations, 'organization').collect_grouped_options

    @services = Service.where(organization_id: @organizations.pluck(:id))
    @grouped_options_services = InvoiceReportGroupedOptions.new(@services, 'service').collect_grouped_options_services

  end

  def create
    parsed_reports_params = parse_json_params(reports_params)
    @document = Document.new(title: parsed_reports_params[:title].humanize, report_type: @report_type)
    
    parsed_reports_params[:core_procedures_option] = parsed_reports_params[:core_procedures_option] || false

    if @document.valid?
      @report = @report_type.classify.constantize.new(parsed_reports_params)
      @errors = @report.errors
      if @report.valid?
        @reports_params = parsed_reports_params
        @documentable.documents.push @document

        params_to_send = parsed_reports_params.to_h
        params_to_send[:permissions] = IdentityOrganizations.new(current_identity.id).authorized_protocols.ids
        ReportJob.perform_later(@document, params_to_send)
      end
    else
      @errors = @document.errors
    end

    respond_to do |format|
      format.js
      format.json {
        render json: { document: { id: @document.id } }
      }
    end
  end

  def update_services_protocols_dropdown
    @single_protocol = (params[:report_type] == "project_summary_report")

    if params[:org_ids]
      @org_ids = JSON.parse(params[:org_ids])
      @protocols = Protocol.includes(:sub_service_request, :sparc_protocol).where(sub_service_request: SubServiceRequest.where(organization_id: @org_ids)).distinct
      @services = Service.where(organization_id: all_child_organizations_with_self(@org_ids)).distinct
      @grouped_options_services = InvoiceReportGroupedOptions.new(@services, 'service').collect_grouped_options_services
    else
      @protocols = current_identity.protocols
    end
  end

  def update_protocols_dropdown
    @single_protocol = (params[:report_type] == "project_summary_report")

    if params[:service_ids]
      @service_ids = JSON.parse(params[:service_ids])
      @protocols = []

      Protocol.includes(:sub_service_request, :sparc_protocol).where(line_items: LineItem.where(service_id: @service_ids)).distinct.each do |protocol|
        @protocols << protocol
      end
      
      Protocol.includes(:sub_service_request, :sparc_protocol).joins(:procedures).where(procedures: Procedure.where(service_id: @service_ids)).distinct.each do |protocol|
        @protocols << protocol
      end

      @protocols

    else
      @protocols = []
      current_identity.protocols.includes(:sparc_protocol).each do |protocol|
        @protocols << protocol
      end

      @protocols
    end
  end

  def reset_services_dropdown
    @organizations = IdentityOrganizations.new(current_identity.id).fulfillment_organizations_with_protocols
    @services = Service.where(organization_id: @organizations.pluck(:id))
    @grouped_options_services = InvoiceReportGroupedOptions.new(@services, 'service').collect_grouped_options_services
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

  def all_child_organizations_with_self(org_ids)
    org_ids = org_ids.compact
    result = []
    unless org_ids.empty?
      result << org_ids

      orgs = Organization.find(org_ids)
      orgs.each do |org|
        result << org.all_child_organizations.pluck(:id)
      end
    end

    result.flatten
  end

  def parse_json_params(params)
    parsed_params = params
    json_param_keys = [:services, :protocols]

    json_param_keys.each do |key|
      if parsed_params[key].is_a?(String)
        begin
          parsed_value = JSON.parse(params[key])
          parsed_params[key] = parsed_value
        rescue JSON::ParserError => e
          # Handle invalid JSON string here, e.g., log the error or return a bad request status
          Rails.logger.error "Failed to parse JSON for param '#{key}': #{params[key]} - #{e.message}"
          render json: { error: "Invalid JSON in '#{key}' parameter" }, status: :bad_request and return
        end
      end
    end

    parsed_params
  end

  def reports_params
    params.require(:report_type) # raises error if report_type not present
    params.permit(:all_protocols_selected,
              :format,
              :core_procedures_option,
              :utf8,
              :report_type,
              :title,
              :start_date,
              :end_date,
              :gender,
              :service_type,
              :time_zone,
              :protocol,
              :protocol_id,
              :sort_by,
              :sort_order,
              :include_notes,
              :include_invoiced,
              :participant_id,
              :protocols_participant_id,
              :documentable_id,
              :documentable_type,
              :protocol_level,
              :services,
              :protocols,
              :mrns => [],
              :organizations => []).merge(identity_id: current_identity.id)
              # :services => [],
              # :protocols => [])
  end
end
