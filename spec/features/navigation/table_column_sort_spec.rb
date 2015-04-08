require "rails_helper"

feature "Table column sort indicators", js: true do

  scenario "User sees sort indicators on all sortable columns" do
    given_protocols_exist
    and_i_am_on_the_protocols_page
    then_i_should_see_sort_indicators_on_each_sortable_column
  end

  scenario "User sorts column" do
    given_i_am_viewing_protocols
    when_i_sort_the_first_sortable_column
    then_i_should_see_a_visual_indication_that_the_column_is_sorted
  end

  scenario "User sorts another column" do
    given_i_am_viewing_protocols
    when_i_sort_multiple_columns
    then_i_should_see_a_visual_indication_that_the_column_is_sorted
  end

  def given_i_am_viewing_protocols
    given_protocols_exist
    and_i_am_on_the_protocols_page
  end

  def when_i_sort_the_first_sortable_column
    first("th .th-inner.sortable").click
  end

  def when_i_sort_multiple_columns
    when_i_sort_the_first_sortable_column
    all("th .th-inner.sortable").last.click
  end

  def given_protocols_exist
    create_list(:protocol_imported_from_sparc, 3)
  end

  def and_i_am_on_the_protocols_page
    visit protocols_path
  end

  def then_i_should_see_sort_indicators_on_each_sortable_column
    expect(page).to have_css("th .th-inner.sortable i.glyphicon-sort")
  end

  def then_i_should_see_a_visual_indication_that_the_column_is_sorted
    expect(page).to have_css("th i.glyphicon.glyphicon-sort-by-attributes-alt", count: 1)
  end
end
