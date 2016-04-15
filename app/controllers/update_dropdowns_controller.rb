class UpdateDropdownsController < ApplicationController

  def create
    org_ids = params[:org_ids]
    @protocols = []
    @protocols = org_ids.flat_map{ |id| find_protocols(id) }
  end

  private

  def find_protocols(org_ids)
    Protocol.find_protocols_by_org_id(org_ids)
  end
end
