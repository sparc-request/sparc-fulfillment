class ProtocolsController < ApplicationController
  respond_to :json, :html

  def index
    status = params[:status] || 'All'
    @protocols = (status == 'All') ? Protocol.all : Protocol.where(status: status)

    respond_with @protocols
  end

  def show
    @protocol = Protocol.find_by(sparc_id: params[:id])
    @services = Service.all
    respond_with [@protocol]
  end
end
