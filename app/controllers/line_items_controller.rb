class LineItemsController < ApplicationController
  respond_to :json, :html

  def new
    @protocol = Protocol.find(params[:protocol_id])
    @services = Service.all
    @line_item = LineItem.new(arm_id: params[:arm_id],service_id: params[:service_id])
  end

  def create
    if params[:arm_id] == nil
      return
    end
    if params[:arm_ids].count > 1
      params[:arm_ids].each do |a|
        @line_item = LineItem.create(arm_id: a, service_id: params[:service_id])
      end
        flash.now[:success] = "Services have been added to the chosen arms"
    else
      @line_item = LineItem.create(arm_id: params[:arm_ids].first, service_id: params[:service_id])
      flash.now[:success] = "Service has been added"
    end
  end

  def destroy#this destoy is only used on the service calendar
    if params[:arm_ids].count > 1
      params[:arm_id].each do |a|
        @line_item = LineItem.create(arm_id: a, service_id: params[:service_id])
      end
        flash.now[:success] = "Services has been removed from the chosen arms"
    else
      @line_item = LineItem.create(arm_id: params[:arm_ids].first, service_id: params[:service_id])
      flash.now[:success] = "Service has been removed"
    end
  end

end
