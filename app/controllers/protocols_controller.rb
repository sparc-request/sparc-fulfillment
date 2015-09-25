class ProtocolsController < ApplicationController

  before_action :find_protocol, only: [:show]
  before_action :authorize_protocol, only: [:show]
  before_action :get_current_tab, only: [:show]

  respond_to :json, :html

  def index
    respond_to do |format|
      format.html { render }
      format.json do
        @protocols = current_identity.protocols

        if params[:status].present? && params[:status] != 'all'
          @protocols = @protocols.select { |protocol| protocol.status == params[:status] }
        end

        render
      end
    end
  end

  def show
    @current_tab = get_current_tab
    @services = @protocol.organization.inclusive_child_services(:per_participant)
    @services_present = @services.present?

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

  def get_current_tab
    cookies['active-protocol-tab'.to_sym] ? cookies['active-protocol-tab'.to_sym] : nil
  end
end
