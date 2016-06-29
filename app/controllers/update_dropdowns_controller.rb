class UpdateDropdownsController < ApplicationController

  def create
    @protocols = Protocol.where(sub_service_request: SubServiceRequest.where(organization_id: params[:org_ids])).distinct
  end
end
