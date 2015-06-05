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
    @visit.update_procedures 0, "insurance_billing_qty"
  end

  def change_visit_name
    @visit_group = VisitGroup.find(params[:visit_group_id])
    name = params[:name]
    @visit_group.update_attributes(name: name)
    @visit_group.appointments.update_all(name: name)
  end

  def change_quantity
    quantity = params[:quantity]
    @qty_type = params[:qty_type]
    @visit = Visit.find params[:visit_id]
    @visit.update_attributes(@qty_type => quantity)
    @visit.update_procedures quantity.to_i, @qty_type
  end

  def edit_service
    @line_item = LineItem.find(params[:line_item_id])
  end

  def update_service
    @line_item = LineItem.find(params[:line_item][:id])
    @line_item.update_attributes(service_id: params[:line_item][:service_id])
    update_line_item_procedures_service(@line_item)
  end

  def check_row
    qty = params[:check] == 'true' ? 1 : 0
    visits = Visit.where(line_item_id: params[:line_item_id])
    visits.update_all(research_billing_qty: qty, insurance_billing_qty: 0, effort_billing_qty: 0)
    visits.each do |visit|
      visit.update_procedures qty.to_i
      visit.update_procedures 0, "insurance_billing_qty"
    end
  end

  def check_column
    qty = params[:check] == 'true' ? 1 : 0
    visits = Visit.where(visit_group_id: params[:visit_group_id])
    visits.update_all(research_billing_qty: qty, insurance_billing_qty: 0, effort_billing_qty: 0)
    visits.each do |visit|
      visit.update_procedures qty.to_i
      visit.update_procedures 0, "insurance_billing_qty"
    end
  end

  def remove_line_item
    line_item = LineItem.find params[:line_item_id]
    @arm_id = line_item.arm_id
    @line_item_id = params[:line_item_id]
    @core_id = line_item.sparc_core_id
    line_item.destroy
    @remove_core = LineItem.joins(:service).where("arm_id = #{@arm_id} and services.organization_id = #{@core_id}").count == 0
  end

  private

  def update_line_item_procedures_service line_item
    # Need to change any procedures that haven't been completed to the new service
    service = line_item.service
    service_name = service.name
    service_cost = service.cost
    line_item.visits.each do |v|
      v.procedures.select{ |p| not(p.appt_started? or p.complete?) }.each do |p|
        p.update_attributes(service_id: service.id, service_name: service_name, service_cost: service_cost)
      end
    end
  end
end
