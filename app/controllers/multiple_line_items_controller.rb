class MultipleLineItemsController < ApplicationController
  respond_to :json, :html
  #this controller exsists in order to seperate the mass creation of line items
  #from single line item creation and deletion which will happen on the service calendar

  def new
    #called to render modal to mass create line items
    @selected_service = params[:service_id]
    @services = Service.all
    @protocol = Protocol.find(params[:protocol_id])
  end

  def edit
    #called to render modal to mass remove line items
    @selected_service = params[:service_id]
    @protocol = Protocol.find(params[:protocol_id])
    @services = Service.all
  end

  def update
    #handles subission of the line item form
    if params[:header_text].include? ("Add")
      create(params)
    else
      destroy(params)
    end
  end

  def create (params)
    if params[:arm_ids] == nil
      return
    end
    params[:arm_ids].each do |a|
      @line_item = LineItem.create(arm_id: a, service_id: params[:service_id])
    end
    flash.now[:success] = "Service(s) have been added to the chosen arms"
  end

  def destroy (params)
    service_id = params[:service_id]
    if params[:arm_ids] == nil
      return
    end
    params[:arm_ids].each do |a|
      if Arm.find(a).line_items.pluck(:service_id).include?(service_id.to_i)
        LineItem.where("arm_id = ? AND service_id = ?", a, service_id).delete_all
      end
    end
    flash.now[:success] = "Service(s) have been removed from the chosen arms"
  end
end
