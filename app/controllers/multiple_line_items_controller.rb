class MultipleLineItemsController < ApplicationController
  respond_to :json, :html
  #this controller exsists in order to seperate the mass creation of line items
  #from single line item creation and deletion which will happen on the service calendar

  def new
    #called to render modal to mass create line items
    @selected_service = params[:service_id]
    @services = Service.all
    @protocol = Protocol.find(params[:protocol_id])
    @page_hash = params[:page_hash]
  end

  def edit
    #called to render modal to mass remove line items
    @selected_service = params[:service_id]
    @protocol = Protocol.find(params[:protocol_id])
    @services = Service.all
    @page_hash = params[:page_hash]
  end

  def update
    #handles submission of the line item form
    if params[:arm_ids]
      @service_id = params[:service_id]
      service = Service.find(@service_id)
      @core_id = service.sparc_core_id
      @core_name = service.sparc_core_name
      @arm_ids = params[:arm_ids].map{ |set| set.split()[0]}

      if params[:header_text].include? ("Add")
        @action = 'create'
        create(params)
      else
        @action = 'destroy'
        destroy(params)
      end
    end
  end

  def create (params)
    @arm_hash = {}
    params[:arm_ids].each do |set|
      arm_id, page = set.split
      @arm_hash[arm_id] = {page: page, line_item: LineItem.create(arm_id: arm_id, service_id: @service_id)}
    end
    flash.now[:success] = "Service(s) have been added to the chosen arms"
  end

  def destroy (params)
    @line_item_ids = {}
    @arm_ids.each do |arm_id|
      line_items = LineItem.where("arm_id = #{arm_id} AND service_id = #{@service_id}")
      if line_items.count > 0
        @line_item_ids[arm_id] = line_items.pluck(:id)
        line_items.delete_all
      end
    end
    flash.now[:success] = "Service(s) have been removed from the chosen arms"
  end
end
