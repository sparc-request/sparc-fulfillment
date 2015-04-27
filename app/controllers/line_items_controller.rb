class LineItemsController < ApplicationController

  before_action :find_line_item, only: [:update]

  def update
    @line_item.update_attributes(line_item_params)
    flash[:success] = t(:flash_messages)[:line_item][:updated]
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
