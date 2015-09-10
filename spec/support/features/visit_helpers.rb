module Features

  module VisitHelpers

    def add_a_service(service, count = 1)
      bootstrap_select '#service_list', service.name
      find('button.add_service').click
      wait_for_ajax
    end

    def given_i_am_viewing_a_visit
      visit participant_path participant
      bootstrap_select '#appointment_select', appointment.name
      wait_for_ajax
    end
  end
end
