module Features

  module VisitHelpers

    def and_the_visit_has_one_grouped_procedure
      2.times { add_a_procedure services.first }
    end

    def add_a_procedure(service, count = 1)
      count.times do
        bootstrap_select '#service_list', service.name
        find('button.add_service').click
        wait_for_ajax
      end
    end

    def given_i_am_viewing_a_visit
      visit participant_path participant
      bootstrap_select '#appointment_select', appointment.name
      wait_for_ajax
    end
  end
end
