require 'rails_helper'

feature 'Identity adds multiple Procedures', js: true do

  let!(:protocol)    { create_and_assign_protocol_to_me }
  let!(:participant) { Participant.first }
  let!(:appointment) { Appointment.first }
  let!(:services)    { protocol.organization.inclusive_child_services(:per_participant) }

  scenario 'which are not part of an existing group' do
    given_i_am_viewing_a_visit
    and_the_visit_has_one_grouped_procedure
    when_i_add_two_different_procedures
    then_i_should_see_two_grouped_procedures
  end

  scenario 'which are part of an existing Service group' do
    given_i_am_viewing_a_visit
    and_the_visit_has_one_grouped_procedure
    when_i_add_two_similar_procedures
    then_i_should_see_one_group_with_four_procedures
  end

  scenario 'and sees the multiselect dropdown instantiated with Select All option and Service option' do
    given_i_am_viewing_a_started_visit
    when_i_add_5_procedures
    then_i_should_see_the_multiselect_instantiated_with_2_options
  end

  def when_i_add_two_similar_procedures
    add_a_procedure services.first, 2
  end

  def when_i_add_two_different_procedures
    add_a_procedure services.last, 2
  end

  def when_i_add_5_procedures
    add_a_procedure services.first, 5
  end

  def then_i_should_see_the_multiselect_instantiated_with_2_options
    find("select#core_multiselect + .btn-group").click
    expect(page).to have_content("Select all")
    expect(page).to have_content("5 #{Procedure.first.service_name} R")
  end

  def then_i_should_see_one_group_with_four_procedures
    group_id = Procedure.first.group_id

    expect(page).to have_css("tr.procedure[data-group-id='#{group_id}']", count: 4)
  end

  def then_i_should_see_two_grouped_procedures
    expect(page).to have_css('tr.procedure-group', count: 2)
  end
end
