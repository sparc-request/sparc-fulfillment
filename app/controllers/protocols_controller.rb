class ProtocolsController < ApplicationController
  def index
    @protocols = Protocol.all
  end

  def show
    @protocol = Protocol.find(params[:id])
    @selected_arm = @protocol.arms.first
    @services = Service.all
  end
end
