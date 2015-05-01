class LineItemsController < ApplicationController

  before_action :find_line_item, only: [:update]

  def update
    @line_item.update_attributes(line_item_params)
    flash[:success] = t(:flash_messages)[:line_item][:updated]
  end

  def create
    service = Service.find(params[:service_id])
    @protocol = Protocol.find(params[:protocol_id])
    @line_item = LineItem.new(service_id: service.id, protocol_id: @protocol.id)
    if @line_item.valid?
      @line_item.save
    end
  end

  private

  def line_item_params
    @line_item_params = params.require(:line_item).permit(:quantity_requested, :started_at)
    @line_item_params[:started_at] = Time.at(@line_item_params[:started_at].to_i / 1000) if @line_item_params[:started_at]

    @line_item_params
  end

  def find_line_item
    @line_item = LineItem.where(id: params[:id]).first
  end
end
