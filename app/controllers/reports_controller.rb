# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

  def update_protocols_dropdown
    @single_protocol = (params[:report_type] == "project_summary_report")

    if params[:org_ids]
      @protocols = Protocol.where(sub_service_request: SubServiceRequest.where(organization_id: params[:org_ids])).distinct
    else
      @protocols = current_identity.protocols
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
    params.permit(:format,
              :utf8,
              :report_type,
              :title,
              :start_date,
              :end_date,
              :service_type,
              :time_zone,
              :protocol,
              :protocol_id,
              :sort_by,
              :sort_order,
              :participant_id,
              :documentable_id,
              :documentable_type,
              :organizations => [],
              :protocols => []).merge(identity_id: current_identity.id)
  end
end
