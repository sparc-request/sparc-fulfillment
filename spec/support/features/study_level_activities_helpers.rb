module Features

  module StudyLevelActivitiesHelpers

    def user_creates_a_note
      wait_for_ajax
      fill_in 'note_comment', with: "Look at me, I'm a comment."
      click_button 'Save'
    end
  end
end