RSpec.configure do |config|

  config.before(:suite) do
    Appointment.paper_trail_off!
    Arm.paper_trail_off!
    Component.paper_trail_off!
    Fulfillment.paper_trail_off!
    LineItem.paper_trail_off!
    Note.paper_trail_off!
    Participant.paper_trail_off!
    Procedure.paper_trail_off!
    Protocol.paper_trail_off!
    Task.paper_trail_off!
    Visit.paper_trail_off!
    VisitGroup.paper_trail_off!
  end
end
