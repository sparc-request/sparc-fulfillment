class UpdateDropdownsController < ApplicationController

  def create
    org_ids = params[:org_ids]
    @protocols = []
    collect_protocols(org_ids)
    @protocols = @protocols.flatten
  end

  private

  def find_protocols(org_ids)
    Protocol.find_protocols_by_org_id(org_ids)
  end

  def collect_protocols(org_ids)
    org_ids.each do |org_id|
      @protocols << find_protocols(org_id)
    end
  end
end
