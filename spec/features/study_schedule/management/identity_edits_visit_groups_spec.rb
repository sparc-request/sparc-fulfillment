# Copyright © 2011-2018 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

feature 'Identity edits visit groups for a particular protocol', js: true do

  context "User adds a visit group to an arm" do
    scenario "and sees the visit group on the arm" do
      given_i_am_viewing_an_arm_with_multiple_visit_groups

      @original_visit_group_1 = @arm.visit_groups.first
      @original_visit_group_2 = @arm.visit_groups.second
      @original_visit_group_1.day = 1
      @original_visit_group_2.day = 3
      @original_visit_group_1.save
      @original_visit_group_2.save

      when_i_click_the_add_visit_group_button
      when_i_fill_in_the_form(day: @arm.visit_groups.last.day + 100)
      when_i_click_the_add_submit_button
      then_i_should_see_the_visit_group
    end

    scenario "and sees it in the correct position" do
      given_i_am_viewing_an_arm_with_multiple_visit_groups

      @original_visit_group_1 = @arm.visit_groups.first
      @original_visit_group_2 = @arm.visit_groups.second
      @original_visit_group_1.day = 1
      @original_visit_group_2.day = 3
      @original_visit_group_1.save
      @original_visit_group_2.save


      when_i_click_the_add_visit_group_button
      when_i_fill_in_the_form(position: "Before #{@arm.visit_groups.second.name} (Day #{@arm.visit_groups.second.day})", day: @arm.visit_groups.second.day-1)
      when_i_click_the_add_submit_button
      then_i_should_see_the_position_is 1
    end
  end

  context "User edits a visit group on an arm" do
    scenario "and sees the updated arm" do
      given_i_am_viewing_an_arm_with_multiple_visit_groups
      when_i_click_the_edit_visit_group_button
      when_i_set_the_name_to 'VG 2'
      when_i_set_the_day_to 2
      when_i_click_the_save_submit_button
      then_i_should_see_the_updated_visit_group
    end
  end

  context "User edits a visit groups name in the service calendar" do
    context "and provides a name" do
      scenario "and sees the updated name" do
        given_i_am_viewing_an_arm_with_one_visit_group
        when_i_enter_the_name "VG YO"
        then_i_should_see_the_name "VG YO"
      end
    end

    context "and leaves the name blank" do
      scenario "and sees the original name" do
        given_i_am_viewing_an_arm_with_one_visit_group
        @original_name = @arm.visit_groups.first.name

        when_i_enter_the_name ""
        then_i_should_see_the_original_name
      end
    end
  end

  context "User deletes a visit group from an arm" do
    scenario "and does not see the visit group on the arm" do
      given_i_am_viewing_an_arm_with_multiple_visit_groups
      when_i_click_the_remove_visit_group_button
      when_i_click_the_remove_submit_button
      then_i_should_not_see_the_visit_group
    end
  end

  def given_i_am_viewing_an_arm_with_multiple_visit_groups
    @protocol = create_and_assign_protocol_to_me
    @protocol.arms.each do |arm|
      arm.destroy
    end

    @arm      = create(:arm_with_visit_groups, visit_count: 2, protocol: @protocol, subject_count: 3)
    @visit_groups = @arm.visit_groups

    visit protocol_path @protocol
    wait_for_ajax
  end

  def given_i_am_viewing_an_arm_with_one_visit_group
    @protocol = create_and_assign_protocol_to_me
    @protocol.arms.each do |arm|
      arm.delete
    end
    @arm      = create(:arm_with_one_visit_group, visit_count: 1, protocol: @protocol, subject_count: 3)

    visit protocol_path @protocol
    wait_for_ajax
  end

  def when_i_click_the_add_visit_group_button
    find("#add_visit_group_button").click
    wait_for_ajax
  end

  def when_i_click_the_edit_visit_group_button
    find("#edit_visit_group_button").click
    wait_for_ajax
  end

  def when_i_click_the_remove_visit_group_button
    find("#remove_visit_group_button").click
    wait_for_ajax
  end

  def when_i_fill_in_the_form(opts = {})
    bootstrap_select "#visit_group_arm_id", "#{@arm.name}"
    fill_in "visit_group_name", with: opts[:name] || "VG"
    fill_in "visit_group_day", with: opts[:day] || "13"
    bootstrap_select "#visit_group_position", opts[:position] || "Add as last"
    wait_for_ajax
  end

  def when_i_set_the_name_to name
    fill_in "visit_group_name", with: name
  end

  def when_i_set_the_day_to day
    fill_in "visit_group_day", with: day
  end

  def when_i_click_the_add_submit_button
    click_button 'Add'
    wait_for_ajax
  end

  def when_i_click_the_remove_submit_button
    click_button 'Remove'
    accept_confirm
    wait_for_ajax
  end

  def when_i_click_the_save_submit_button
    click_button "Save"
    wait_for_ajax
  end

  def when_i_set_the_position_to position_identifier
    bootstrap_select "#visit_group_position", position_identifier
  end

  def when_i_enter_the_name name
    fill_in "visit_group_#{@arm.visit_groups.first.id}", with: name
    wait_for_ajax

    first(".study_schedule_table_name").click
    wait_for_ajax
  end

  def then_i_should_see_the_visit_group
    expect(page).to have_css("input[value='VG']")
  end

  def then_i_should_see_the_updated_visit_group
    vg_id = @arm.visit_groups.first.id
    expect(find("#visit_group_#{vg_id}").value).to eq("VG 2")
  end

  def then_i_should_not_see_the_visit_group
    expect(page).to have_no_selector(".visit_name", text: @visit_groups.first.name)
  end

  def then_i_should_see_the_position_is position
    wait_for_ajax
    @new_visit_group = @arm.visit_groups.find_by_name("VG")

    within(".visit_groups_for_#{@arm.id}") do
      expect(page.all(".visit_name")[0].value).to eq(@original_visit_group_1.name)
      expect(page.all(".visit_name")[1].value).to eq(@new_visit_group.name)
      expect(page.all(".visit_name")[2].value).to eq(@original_visit_group_2.name)
    end
  end

  def then_i_should_see_the_name name
    expect(find("#visit_group_#{@arm.visit_groups.first.id}").value).to eq(name)
  end

  def then_i_should_see_the_original_name
    expect(find("#visit_group_#{@arm.visit_groups.first.id}").value).to eq(@original_name)
  end
end
