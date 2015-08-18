require 'rails_helper'

feature 'Identity edits services for a particular protocol', js: true, enqueue: false do

  scenario 'identity adds service to arm(s)' do
    given_an_arm_with_services
    when_i_add_services_to_an_arm
    then_i_should_see_them_on_that_arm
  end

  scenario 'identity deletes service from arm(s)' do
    given_an_arm_with_services
    when_i_remove_services_from_an_arm
    then_i_should_not_see_it_on_that_arm
  end

  def given_an_arm_with_services
    @protocol  = create_and_assign_protocol_to_me
    @protocol.arms.each{|a| a.delete}
    @protocol.line_items.each{|li| li.delete}
    @services  = @protocol.organization.inclusive_child_services(:per_participant)
    @arm       = create(:arm_with_visit_groups, protocol: @protocol)
    @line_item = create(:line_item, arm: @arm, service: @services.first, protocol: @protocol)

    Service.all.each do |s| #Clean up services otherwise service may not show up unless list scrolled
      s.delete if !@services.include?(s)
    end
    
    visit protocol_path @protocol
  end

  def when_i_add_services_to_an_arm
    find("#add_service_button").click
    
    bootstrap_select "#add_service_id", "#{@services.last.name}"
    
    bootstrap_select "#add_service_arm_ids_and_pages_", @arm.name
    find("h4#line_item").click # click out of bootstrap multiple select
    
    click_button "Add"
  end

  def when_i_remove_services_from_an_arm
    find("#remove_service_button").click
    wait_for_ajax

    bootstrap_select "#remove_service_id", "#{@protocol.organization.services.first.name}"
    find("h4#line_item").click # click out of bootstrap multiple select
    
    bootstrap_select "#remove_service_arm_ids_", "#{@arm.name}"
    find("h4#line_item").click # click out of bootstrap multiple select
    
    click_button "Remove"
  end

  def then_i_should_see_them_on_that_arm
    arm = find(".arm_#{@arm.id}")
    expect(arm).to have_content "#{@services.last.name}"
  end

  def then_i_should_not_see_it_on_that_arm
    arm = find(".arm_#{@arm.id}")
    expect(arm).not_to have_content "#{@services.first.name}"
  end
end
