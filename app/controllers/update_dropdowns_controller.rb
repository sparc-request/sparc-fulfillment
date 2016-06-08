class UpdateDropdownsController < ApplicationController

  def create
    org_ids = params[:org_ids]
    @protocols = Protocol.find_protocols_by_org_id(org_ids)
  end
end
