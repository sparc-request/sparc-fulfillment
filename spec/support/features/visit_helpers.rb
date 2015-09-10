module Features

  module VisitHelpers

    def given_i_am_viewing_a_visit
      visit participant_path participant
      bootstrap_select '#appointment_select', appointment.name
      wait_for_ajax
    end
  end
end
