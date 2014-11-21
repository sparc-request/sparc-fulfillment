class ProtocolsController < ApplicationController
  respond_to :json, :html
  def index
    @protocols = Protocol.all
    respond_with @protocols
  end

  def show
    @protocol = Protocol.find(params[:id])
  end

  def protocols_by_status
    puts "<>"*100
    puts params
    status = params[:status] || 'Complete'
    @protocols = Protocol.where(status: status)
    respond_with @protocols
  end

end
