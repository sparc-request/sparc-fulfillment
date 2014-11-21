class ProtocolsController < ApplicationController
  respond_to :json, :html
  def index
    @protocols = Protocol.all
    respond_with @protocols
  end

  def show
    @protocol = Protocol.find(params[:id])
    @selected_arm = @protocol.arms.first
    @services = Service.all
    @protocol = Protocol.find_by_sparc_id(params[:id])
  end

end
