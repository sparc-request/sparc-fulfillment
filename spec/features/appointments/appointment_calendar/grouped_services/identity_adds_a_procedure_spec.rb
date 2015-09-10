require 'rails_helper'

feature 'Identity adds a Procedure', js: true do

  let!(:protocol)     { create_and_assign_protocol_to_me }
  let!(:participant)  { Participant.first }
  let!(:appointment)  { Appointment.first }
  let!(:services)     { protocol.organization.inclusive_child_services(:per_participant) }

  scenario 'and sees the procedure in the correct Core' do
    given_i_am_viewing_a_visit
    when_i_add_a_procedure
    then_i_should_see_a_core
  end

  scenario 'which is part of an existing group and sees the Procedure in a group' do
    given_i_am_viewing_a_visit
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_three_procedures_in_the_group
  end

  scenario 'which is not part of a group and does not see the Procedure in a group' do
    given_i_am_viewing_a_visit
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_different_procedure
    then_i_should_not_see_the_procedure_in_the_group
  end

  scenario 'which is not part of an existing group and sees a Procedure group created' do
    given_i_am_viewing_a_visit
    and_the_visit_has_one_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_two_procedures_in_the_group
  end

  scenario 'which is part of an existing group and sees the group counter incremented' do
    given_i_am_viewing_a_visit
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_the_group_counter_is_correct
  end

  def when_i_add_a_procedure
    add_a_procedure services.first
  end

  def when_i_add_a_different_procedure
    add_a_procedure services.last
  end

  def then_i_should_see_the_group_counter_is_correct
    group_id = Procedure.first.group_id

    expect(page).to have_css("tr.procedure-group[data-group-id='#{group_id}'] span.count", text: '3')
  end

  def then_i_should_not_see_the_procedure_in_the_group
    group_id = Procedure.last.group_id

    expect(page).to have_css("tr.procedure[data-group-id='#{group_id}']", count: 1)
  end

  def then_i_should_see_two_procedures_in_the_group
    group_id = Procedure.first.group_id

    expect(page).to have_css("tr.procedure[data-group-id='#{group_id}']", count: 2)
  end

  def then_i_should_see_three_procedures_in_the_group
    group_id = Procedure.first.group_id

    expect(page).to have_css("tr.procedure[data-group-id='#{group_id}']", count: 3)
  end

  def then_i_should_see_a_core
    expect(page).to have_css('.core')
  end

  alias :and_the_visit_has_one_procedure :when_i_add_a_procedure
  alias :when_i_add_a_similar_procedure :when_i_add_a_procedure
end
