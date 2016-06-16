class UpdateDropdownsController < ApplicationController

  def create
    org_ids = params[:org_ids]
    ssrs = SubServiceRequest.where(organization_id: org_ids)
    @protocols = ssrs.map(&:protocol)
  end
end
