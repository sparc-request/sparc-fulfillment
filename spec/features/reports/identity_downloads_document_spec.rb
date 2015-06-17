require 'rails_helper'

feature 'Identity downloads Document', js: true do

  scenario 'and sees the unread Documents counter decremented' do
    given_i_have_requested_a_report
    when_i_download_the_report
    then_i_should_see_that_i_have_no_unaccessed_documents
  end

  def given_i_have_requested_a_report
    identity = Identity.first
    document = create(:document_with_csv_file,
                        state: "Completed",
                        documentable_id: identity.id,
                        documentable_type: 'Identity')
    identity.update_counter :unaccessed_documents, 1

    visit documents_path
  end

  def when_i_download_the_report
    find('table.documents a.attached_file').click
    visit documents_path
  end

  def then_i_should_see_that_i_have_no_unaccessed_documents
    expect(page).to have_css('.notification.document-notifications', text: '0')
  end
end
