class MultipleLineItemsController < ApplicationController
  respond_to :json, :html
  #this controller exists in order to separate the mass creation of line items
  #from single line item creation and deletion which will happen on the study schedule

  def new_line_items
    #called to render modal to mass create line items
    @protocol = Protocol.find params[:protocol_id]
    @services = @protocol.organization.inclusive_child_services(:per_participant)
    @page_hash = params[:page_hash]
    @schedule_tab = params[:schedule_tab]
  end

  def create_line_items
    #handles submission of the add line items form
    if params[:add_service_arm_ids_and_pages] #if arms are selected
      @service = Service.find(params[:add_service_id])
      arm_ids_and_pages = params[:add_service_arm_ids_and_pages].map do |set|
        arm_id, page = set.split
        [arm_id, [Arm.find(arm_id), page]]
      end
      # check if service is already on one of the selected arms
      arm_ids_and_pages.each do |k,v|
        arm = v[0]
        @service.errors.add(:service, "'#{@service.name}' is already present on Arm '#{arm.name}'") if arm.line_items.map(&:service_id).include? @service.id
      end
      unless @service.errors.present? # if service is not on any selected arms
        @schedule_tab = params[:schedule_tab]
        @arm_hash = {}
        arm_ids_and_pages.each do |k,v|
          arm_id, arm, page = [k,v].flatten
          line_item = LineItem.new(protocol_id: arm.protocol_id, arm_id: arm_id, service_id: @service.id, subject_count: arm.subject_count)
          importer = LineItemVisitsImporter.new(line_item)
          importer.save_and_create_dependents
          @arm_hash[arm_id] = {page: page, line_item: line_item}
        end
        flash.now[:success] = t(:services)[:created]
      else
        @errors = @service.errors
      end
    end
  end

  def edit_line_items
    #called to render modal to mass remove line items
    @protocol = Protocol.find params[:protocol_id]
    @all_services = @protocol.arms.map{ |arm| arm.line_items.map{ |li| li.service } }.flatten.uniq
    @service = params[:service_id].present? ? Service.find(params[:service_id]) : @all_services.first
    @arms = @protocol.arms.select{ |arm| arm.line_items.detect{|li| li.service_id == @service.id} }
  end

  def destroy_line_items
    #handles submission of the remove line items form
    if params[:remove_service_arm_ids] #if arms are selected
      @service = Service.find(params[:remove_service_id])
      @arm_ids = [params[:remove_service_arm_ids]].flatten
      line_items = @arm_ids.map{ |arm_id| LineItem.where("arm_id = #{arm_id} AND service_id = #{@service.id}").first }
      @line_item_ids = line_items.map(&:id)
      flash.now[:success] = t(:services)[:deleted]
    end
  end
end
