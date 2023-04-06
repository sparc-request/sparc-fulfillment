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
    @document = Document.new(title: reports_params[:title].humanize, report_type: @report_type)

    @report = @report_type.classify.constantize.new(reports_params)
    @errors = @report.errors
    if @report.valid?
      @reports_params = reports_params
      @documentable.documents.push @document
      ReportJob.perform_later(@document, reports_params.to_h)
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
      @protocols = Protocol.where(sub_service_request: SubServiceRequest.where(organization_id: params[:org_ids])).distinct
      @services = Service.where(organization_id: all_child_organizations_with_self(params[:org_ids])).distinct
      @grouped_options_services = InvoiceReportGroupedOptions.new(@services, 'service').collect_grouped_options_services
    else
      @protocols = current_identity.protocols
    end
  end

  def update_protocols_dropdown
    @single_protocol = (params[:report_type] == "project_summary_report")

    if params[:service_ids]
      @protocols = []
      base_protocols = Protocol.includes(:sub_service_request, :line_items, protocols_participants: [appointments: [:procedures]])

      #These are separated into different queries because acitverecord is stalling out when attempting to chain them together with an 'or' method
      @protocols << base_protocols.where(line_items: {service_id: params[:service_ids]})
      @protocols << base_protocols.where(procedures: {service_id: params[:service_ids]})
      @protocols = @protocols.flatten
    else
      @protocols = current_identity.protocols
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

  def reports_params
    params.require(:report_type) # raises error if report_type not present
    params.permit(:format,
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
              :mrns => [],
              :organizations => [],
              :services => [], 
              :protocols => []).merge(identity_id: current_identity.id)
  end
end
