class ProtocolsController < ApplicationController

  before_action :find_protocol, only: [:show]
  before_action :authorize_protocol, only: [:show]

  respond_to :json, :html

  def index
    respond_to do |format|
      format.html { render }
      format.json do
        @protocols = current_identity.protocols

        if params[:status].present? && params[:status] != 'All'
          @protocols = @protocols.select { |protocol| protocol.status == params[:status] }
        end

        render
      end
    end
  end

  def show
    @services = @protocol.organization.inclusive_child_services(:per_participant)
    @per_participant = @services.present?

    @page = 1

    gon.push({ protocol_id: @protocol.id })
  end

  private

  def find_protocol
    unless @protocol = Protocol.where(id: params[:id]).first
      flash[:alert] = t(:protocol)[:flash_messages][:not_found]
      redirect_to root_path
    end
  end
end
