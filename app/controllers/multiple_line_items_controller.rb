class MultipleLineItemsController < ApplicationController
  respond_to :json, :html
  #this controller exists in order to separate the mass creation of line items
  #from single line item creation and deletion which will happen on the study schedule

  def new_line_items
    #called to render modal to mass create line items
    @selected_service = params[:service_id]
    @protocol = Protocol.find params[:protocol_id]
    @services = @protocol.organization.inclusive_child_services(:per_participant)
    @page_hash = params[:page_hash]
    @schedule_tab = params[:schedule_tab]
    @arm_ids = @protocol.arms.map(&:id)
  end

  def create_line_items
    #handles submission of the add line items form
    @service_id = params[:service_id]
    service = Service.find(@service_id)
    @core_id = service.sparc_core_id
    @schedule_tab = params[:schedule_tab]
    @core_name = service.sparc_core_name
# **********
    @action = 'create'
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

  def edit_line_items
    #called to render modal to mass remove line items
    @protocol = Protocol.find params[:protocol_id]
    @all_services = @protocol.arms.map{ |arm| arm.line_items.map{ |li| li.service } }.flatten.uniq
    @page_hash = params[:page_hash]
    @schedule_tab = params[:schedule_tab]
    @service = params[:service_id].present? ? Service.find(params[:service_id]) : @all_services.first
    @arms = @protocol.arms.select{ |arm| arm.line_items.detect{|li| li.service_id == @service.id} }
  end

  def destroy_line_items
    #handles submission of the remove line items form
    @service_id = params[:service_id]
    service = Service.find(@service_id)
    @core_id = service.sparc_core_id
    @schedule_tab = params[:schedule_tab]
    @core_name = service.sparc_core_name
# **********
    @action = 'destroy'
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
