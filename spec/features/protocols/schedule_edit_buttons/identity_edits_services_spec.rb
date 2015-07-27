require 'rails_helper'

feature 'Identity edits services for a particular protocol', js: true, enqueue: false do

  scenario 'identity adds service to arm(s)' do
    given_an_arm_with_services
    when_i_add_services_to_an_arm
    then_i_should_see_them_on_that_arm
  end

  scenario 'identity deletes service from arm(s)' do
    given_an_arm_with_services
    then_i_should_only_see_services_on_that_arm
    when_i_remove_services_from_an_arm
    then_i_should_not_see_it_on_that_arm
  end

  def given_an_arm_with_services
    @protocol  = create_and_assign_protocol_to_me
    @protocol.arms.each{|a| a.delete}
    @services  = @protocol.organization.inclusive_child_services(:per_participant)
    @arm       = create(:arm_with_visit_groups, protocol: @protocol)
    @line_item = create(:line_item, arm: @arm, service: @services.first, protocol: @protocol)

    visit protocol_path @protocol
  end

  def when_i_add_services_to_an_arm
    find("#add_service_button").click
    bootstrap_select "#service_id", "#{@services.last.name}"
    find("#arm_ids_[value='#{@arm.id} 1']").set(true)
    find("input[type='submit']").click
  end

  def when_i_remove_services_from_an_arm
    find("#arm_ids_[value='#{@arm.id} 1']").set(true)
    find("input[type='submit']").click
  end

  def then_i_should_see_them_on_that_arm
    arm = find(".arm_#{@arm.id}")
    expect(arm).to have_content "#{@services.last.name}"
  end

  def then_i_should_not_see_it_on_that_arm
    arm = find(".arm_#{@arm.id}")
    expect(arm).not_to have_content "#{@services.first.name}"
  end

  def then_i_should_only_see_services_on_that_arm
    find("#remove_service_button").click
    bootstrap_select "#service_id", "#{@services.first.name}"
    assert_selector(".arm-checkbox > label", count: 1)
  end

end
