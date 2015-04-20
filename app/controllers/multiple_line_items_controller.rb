class MultipleLineItemsController < ApplicationController
  respond_to :json, :html
  #this controller exsists in order to seperate the mass creation of line items
  #from single line item creation and deletion which will happen on the service calendar

  def new_line_items
    #called to render modal to mass create line items
    @selected_service = params[:service_id]
    @services = Service.all
    @protocol = Protocol.find(params[:protocol_id])
    @page_hash = params[:page_hash]
    @calendar_tab = params[:calendar_tab]
  end

  def edit_line_items
    #called to render modal to mass remove line items
    @selected_service = params[:service_id]
    @protocol = Protocol.find(params[:protocol_id])
    @services = @protocol.arms.map{ |arm| arm.line_items.map{ |li| li.service } }.flatten.uniq
    @page_hash = params[:page_hash]
    @calendar_tab = params[:calendar_tab]
  end

  def update_line_items
    #handles submission of the line item form
    if params[:arm_ids]
      @service_id = params[:service_id]
      service = Service.find(@service_id)
      @core_id = service.sparc_core_id
      @calendar_tab = params[:calendar_tab]
      @core_name = service.sparc_core_name

      if params[:header_text].include? ("Add")
        @action = 'create'
        create(params)
      else
        @action = 'destroy'
        destroy(params)
      end
    end
  end

  def necessary_arms
    protocol = Protocol.find(params[:protocol_id])
    service_id = params[:service_id]
    @arm_ids = protocol.arms.map{ |arm| arm.id if arm.line_items.detect{|li| li.service_id.to_s == service_id} }
  end

  private

  def create (params)
    @arm_hash = {}
    params[:arm_ids].each do |set|
      arm_id, page = set.split
      arm = Arm.find(arm_id)
      line_item = LineItem.new(protocol_id: arm.protocol_id, arm_id: arm_id, service_id: @service_id, subject_count: arm.subject_count)
      importer = LineItemVisitsImporter.new(line_item)
      importer.save_and_create_dependents
      @arm_hash[arm_id] = {page: page, line_item: line_item}
    end
    flash.now[:success] = t(:services)[:created]
  end

  def destroy (params)
    @line_item_ids = {}
    params[:arm_ids].each do |set|
      arm_id = set.split()[0]
      line_items = LineItem.where("arm_id = #{arm_id} AND service_id = #{@service_id}")
      if line_items.count > 0
        @line_item_ids[arm_id] = line_items.pluck(:id)
        line_items.destroy_all
      end
    end
    flash.now[:success] = t(:services)[:deleted]
  end
end
