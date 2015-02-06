class ServiceCalendarController < ApplicationController
  def change_page
    @page = params[:page]
    @arm = Arm.find params[:arm_id]
    @protocol = @arm.protocol
    @tab = params[:tab]
    @visit_groups = @arm.visit_groups.paginate(page: @page)
  end

  def change_tab
    @arms_and_pages = {}
    hash = params[:arms_and_pages]
    hash.each do |arm_id, page|
      arm = Arm.find(arm_id)
      @arms_and_pages[arm_id] = {arm: arm, page: page}
    end
    @tab = params[:tab]
  end

  def check_visit
    @visit = Visit.find(params[:visit_id])
    qty = params[:checked] == 'true' ? 1 : 0
    @visit.update_attributes(research_billing_qty: qty, insurance_billing_qty: 0, effort_billing_qty: 0)
    @visit.update_procedures qty.to_i
  end

  def change_visit_name
    @visit_group = VisitGroup.find(params[:visit_group_id])
    name = params[:name]
    @visit_group.update_attributes(name: name)
    # TODO: Need to change appointments name to new visit group name
  end

  def change_quantity
    quantity = params[:quantity]
    qty_type = params[:qty_type]
    @visit = Visit.find params[:visit_id]
    @visit.update_attributes(qty_type => quantity)
    @visit.update_procedures quantity.to_i, qty_type
    # TODO: Need to update procedures with correct number based on quantity
    # Need to make sure not to touch completed procedures
  end

  def change_service
    @line_item = LineItem.find(params[:line_item_id])
    @line_item.update_attributes(service_id: params[:service_id])
    # TODO: Need to change any procedures that haven't been completed to the new service
  end

  def check_row
    qty = params[:check] == 'true' ? 1 : 0
    visits = Visit.where(line_item_id: params[:line_item_id])
    visits.update_all(research_billing_qty: qty, insurance_billing_qty: 0, effort_billing_qty: 0)
    visits.each do |visit|
      visit.update_procedures qty.to_i
    end
  end

  def check_column
    qty = params[:check] == 'true' ? 1 : 0
    visits = Visit.where(visit_group_id: params[:visit_group_id])
    visits.update_all(research_billing_qty: qty, insurance_billing_qty: 0, effort_billing_qty: 0)
    visits.each do |visit|
      puts visit.inspect
      visit.update_procedures qty.to_i
    end
  end

  def remove_line_item
    line_item = LineItem.find params[:line_item_id]
    @arm_id = line_item.arm_id
    @line_item_id = params[:line_item_id]
    @core_id = line_item.sparc_core_id
    line_item.destroy
    @remove_core = LineItem.joins(:service).where("arm_id = #{@arm_id} and services.sparc_core_id = #{@core_id}").count > 0 ? false : true
  end

end
