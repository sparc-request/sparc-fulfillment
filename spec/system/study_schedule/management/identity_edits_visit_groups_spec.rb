# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

RSpec.describe 'Identity edits visit groups for a particular protocol', type: :system, js: true do
  let(:identity) { @logged_in_identity }
  let(:protocol) { create_and_assign_protocol_to_me(identity: identity) }

  # Clear default arms to ensure a perfectly clean slate for VG testing
  before { protocol.arms.destroy_all }

  describe 'adding a visit group to an arm' do
    let(:arm) { create(:arm_with_visit_groups, visit_count: 2, protocol: protocol, subject_count: 3) }
    let(:vg1) { arm.visit_groups.first }
    let(:vg2) { arm.visit_groups.second }

    # Safely evaluate and update the data AFTER the auth lifecycle has completed
    before do
      vg1.update(day: 1)
      vg2.update(day: 3)
    end

    it 'should display the new visit group on the arm' do
      given_i_am_viewing_the_study_schedule
      when_i_open_the_add_visit_group_modal
      and_i_fill_in_the_add_form(arm_name: arm.name, name: 'VG', day: vg2.day + 100, position: 'Add as last')
      then_i_should_see_the_visit_group('VG')
    end

    it 'should display the new visit group in the correct position' do
      given_i_am_viewing_the_study_schedule
      when_i_open_the_add_visit_group_modal
      and_i_fill_in_the_add_form(
        arm_name: arm.name,
        name: 'VG',
        day: vg2.day - 1,
        position: "Before #{vg2.name} (Day #{vg2.day})"
      )
      then_i_should_see_the_visit_group_in_position('VG', position: 2, arm: arm)
    end
  end

  describe 'editing a visit group on an arm' do
    let(:arm) { create(:arm_with_visit_groups, visit_count: 2, protocol: protocol, subject_count: 3) }
    let(:vg)  { arm.visit_groups.first }

    # Safely instantiate the chain
    before { vg }

    it 'should update and display the updated visit group' do
      given_i_am_viewing_the_study_schedule
      when_i_open_the_edit_visit_group_modal
      and_i_update_the_visit_group(name: 'VG 2', day: 2)
      then_i_should_see_the_updated_visit_group(vg, 'VG 2')
    end
  end

  describe 'inline editing a visit group name in the service calendar' do
    let(:arm) { create(:arm_with_one_visit_group, visit_count: 1, protocol: protocol, subject_count: 3) }
    let(:vg)  { arm.visit_groups.first }

    before { vg }

    context 'providing a valid name' do
      it 'should update and display the new name' do
        given_i_am_viewing_the_study_schedule
        when_i_inline_edit_the_name(vg, 'VG YO')
        then_i_should_see_the_updated_visit_group(vg, 'VG YO')
      end
    end

    context 'leaving the name blank' do
      it 'should revert to and display the original name' do
        original_name = vg.name
        given_i_am_viewing_the_study_schedule
        when_i_inline_edit_the_name(vg, '')
        then_it_should_revert_to_the_original_name(vg, original_name)
      end
    end
  end

  describe 'deleting a visit group from an arm' do
    let(:arm) { create(:arm_with_visit_groups, visit_count: 2, protocol: protocol, subject_count: 3) }
    let(:vg_to_delete) { arm.visit_groups.first }

    before { vg_to_delete }

    it 'should remove the visit group from the arm' do
      given_i_am_viewing_the_study_schedule
      when_i_open_the_remove_visit_group_modal
      and_i_remove_the_visit_group
      then_i_should_not_see_the_visit_group(vg_to_delete)
    end
  end

  def given_i_am_viewing_the_study_schedule
    visit protocol_path(protocol)
    expect(page).to have_css('#add_visit_group_button', visible: true)
  end

  def when_i_open_the_add_visit_group_modal
    find('#add_visit_group_button').click
    expect(page).to have_css('.modal-title', text: /Add Visit/i, visible: true)
  end

  def when_i_open_the_edit_visit_group_modal
    find('#edit_visit_group_button').click
    expect(page).to have_css('.modal-title', text: /Edit Visit/i, visible: true)
  end

  def when_i_open_the_remove_visit_group_modal
    find('#remove_visit_group_button').click
    expect(page).to have_css('.modal-title', text: /Remove Visit/i, visible: true)
  end

  def and_i_fill_in_the_add_form(arm_name:, name:, day:, position:)
    within('.modal-content', text: /Add Visit/i) do
      bootstrap_select('#visit_group_arm_id', arm_name)
      fill_in 'visit_group_name', with: name
      fill_in 'visit_group_day', with: day
      bootstrap_select('#visit_group_position', position)

      find('input[type="submit"]').click
    end
    
    expect(page).to have_no_css('.modal-content', text: /Add Visit/i)
  end

  def and_i_update_the_visit_group(name:, day:)
    within('.modal-content', text: /Edit Visit/i) do
      fill_in 'visit_group_name', with: name
      fill_in 'visit_group_day', with: day

      click_button 'Submit'
    end
    
    expect(page).to have_no_css('.modal-content', text: /Edit Visit/i, wait: 10)
  end

  def when_i_inline_edit_the_name(vg, new_name)
    input = find("#visit_group_#{vg.id}")
    input.click
    input.set(new_name)

    # Trigger blur natively
    find('body').click(x: 0, y: 0)
  end

  def and_i_remove_the_visit_group
    within('.modal-content', text: /Remove Visit/i) do
      find('#removeVisitGroupButton').click
    end

    expect(page).to have_css('.swal2-container', visible: true)

    within('.swal2-container') do
      find('button.swal2-confirm').click
    end

    expect(page).to have_no_css('.swal2-container')
    expect(page).to have_no_css('.modal-content', text: /Remove Visit/i, wait: 10)
  end

  def then_i_should_see_the_visit_group(name)
    expect(page).to have_css("input[value='#{name}']", visible: true)
  end

  def then_i_should_see_the_visit_group_in_position(name, position:, arm:)
    expect(page).to have_css(".visit_groups_for_#{arm.id} .visit_group_box:nth-child(#{position}) input[value='#{name}']", visible: true)
  end

  def then_i_should_see_the_updated_visit_group(vg, expected_name)
    expect(page).to have_css("#visit_group_#{vg.id}[value='#{expected_name}']", visible: true)
  end

  def then_it_should_revert_to_the_original_name(vg, original_name)
    visit protocol_path(protocol)

    expect(page).to have_css("#visit_group_#{vg.id}[value='#{original_name}']", visible: true)
  end

  def then_i_should_not_see_the_visit_group(vg)
    expect(page).to have_no_css("#visit_group_#{vg.id}")
  end
end
