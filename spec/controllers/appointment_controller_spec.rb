require 'rails_helper'

RSpec.describe AppointmentsController do
  before :each do
    @identity = create(:identity)
    sign_in @identity
    @protocol = create(:protocol_imported_from_sparc)
    @service = create(:service)
    @arm = @protocol.arms.first
    @participant = create(:participant, arm: @arm, protocol: @protocol)
    @custom_appointment = create(:custom_appointment, participant: @participant, arm: @arm, name: "Custom Visit")
  end

  describe "GET #new" do
    it "should instantiate a new custom appointment" do
      xhr :get, :new, {
        custom_appointment: { participant_id: @participant.id, arm_id: @arm.id },
        format: :js
      }
      expect(assigns(:appointment)).to be_a_new(CustomAppointment)
      expect(assigns(:note)).to be_a_new(Note)
    end
  end

  describe "POST #create" do
    it "should create a new custom appointment" do
      attributes = @custom_appointment.attributes
      bad_attributes = ["id", "deleted_at", "created_at", "updated_at"]
      attributes.delete_if {|key| bad_attributes.include?(key)}
      expect{
        post :create, {
          custom_appointment: attributes,
          format: :js
        }
      }.to change(CustomAppointment, :count).by(1)
    end
  end

  describe "GET #show" do

    before :each do
      protocol = create(:protocol_imported_from_sparc)
      visit = Visit.first.update_attributes(research_billing_qty: 1)
      @appointment = Appointment.first
    end

    it "should initialize procedures when there aren't any" do
      expect {
        xhr :get, :show, {
          id: @appointment.id,
          format: :js
        }
      }.to change(Procedure, :count).by(1)
      expect(assigns(:appointment)).to eq(@appointment)
    end

    it "renders the #show view" do
      xhr :get, :show, id: @appointment.id, format: :js
      expect(response).to render_template :show
    end
  end

  describe "GET #completed_appointments" do
    it 'get only the completed appointments for the participant' do
    end
  end

  describe "PATCH #update" do
    it "should set the completed date if one doesn't exist" do
      today = Time.current.strftime("%F")
      appointment = create(:appointment, start_date: Time.current, completed_date: nil, arm: @arm, name: "Visit 1", participant: @participant)
      expect(appointment.completed_date).to eq(nil)
      patch :update, {
        id: appointment.id,
        field: 'completed_date',
        format: :js
      }
      expect(assigns(:appointment).start_date.strftime("%F")).to eq(today)
    end

    it "should change the completed date to the new date" do
      tomorrow = Time.now.tomorrow
      appointment = create(:appointment, start_date: Time.current, completed_date: Time.now, arm: @arm, name: "Visit 1", participant: @participant)
      patch :update, {
        id: appointment.id,
        field: 'completed_date',
        new_date: (tomorrow.to_i)*1000, #expects milliseconds
        format: :js
      }
      expect(assigns(:appointment).completed_date.strftime("%F")).to eq(tomorrow.strftime("%F"))
    end

    it "should change the completed date to the start date if the completed date is nil and the start date is in the future" do
      appointment = create(:appointment, completed_date: nil, start_date: Time.now.tomorrow, arm: @arm, name: "Visit 1", participant: @participant)
      expect(appointment.completed_date).to eq(nil)
      patch :update, {
        id: appointment.id,
        field: 'completed_date',
        format: :js
      }
      expect(assigns(:appointment).completed_date.strftime("%F")).to eq(assigns(:appointment).start_date.strftime("%F"))
    end

    it "should remove the completed date" do
      appointment = create(:appointment, completed_date: nil, start_date: Time.now, completed_date: Time.now.tomorrow, arm: @arm, name: "Visit 1", participant: @participant)
      patch :update ,{
        id: appointment.id,
        field: "completed_date",
        new_date: "",
        format: :js
      }
      appointment.reload
      expect(appointment.completed_date).to eq(nil)
    end

    it "should remove the start date and reset the appointment" do
      appointment = create(:appointment_with_procedures, start_date: Time.now, arm: @arm, name: "Visit 1", participant: @participant, visit_group: @arm.visit_groups.first)
      task        = create(:task, due_at: "09-02-2022", complete: false, assignable_type: "Procedure", assignable_id: appointment.procedures.first.id, assignee_id: @identity.id)
      appointment.procedures.each{ |procedure| procedure.update_attributes(status: "completed", completed_date: "09-12-2022") }

      patch :update, {
        id: appointment.id,
        field: "start_date",
        new_date: "",
        format: :js
      }
      appointment.reload
      expect(appointment.start_date).to eq(nil)
      appointment.procedures.each do |procedure|
        expect(procedure.status).to eq "unstarted"
        expect(procedure.completed_date).to eq(nil)
        expect(procedure.task).to eq(nil)
      end
    end

    it "should set the start date if one doesn't exist" do
      today = Time.current.strftime("%F")
      appointment = create(:appointment, start_date: nil, arm: @arm, name: "Visit 1", participant: @participant)
      expect(appointment.start_date).to eq(nil)
      patch :update, {
        id: appointment.id,
        field: 'start_date',
        format: :js
      }
      expect(assigns(:appointment).start_date.strftime("%F")).to eq(today)
    end

    it "should change the start date to the new date" do
      tomorrow = Time.now.tomorrow
      appointment = create(:appointment, start_date: Time.now, arm: @arm, name: "Visit 1", participant: @participant)
      patch :update, {
        id: appointment.id,
        field: 'start_date',
        new_date: (tomorrow.to_i)*1000, #expects milliseconds
        format: :js
      }
      expect(assigns(:appointment).start_date.strftime("%F")).to eq(tomorrow.strftime("%F"))
    end
  end
end
