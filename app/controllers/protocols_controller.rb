class ProtocolsController < ApplicationController
  respond_to :json, :html
  def index
    status = params[:status] || 'Complete'
    @protocols = (status == 'All') ? Protocol.all : Protocol.where(status: status)
    respond_with @protocols
  end

  def show
    @protocol = Protocol.find(params[:id])
  end
end
