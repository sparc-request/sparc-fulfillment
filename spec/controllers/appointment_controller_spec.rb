require 'rails_helper'

RSpec.describe AppointmentsController do
  before :each do
    @identity = create(:identity)
    sign_in @identity
    @protocol = create(:protocol_imported_from_sparc)
    @service = create(:service)
    @arm = @protocol.arms.first
    @participant = create(:participant, arm: @arm, protocol: @protocol)
    @custom_appointment = create(:custom_appointment, participant: @participant, arm: @arm, name: "Custom Visit", position: 1)
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
    it "should save the start date" do
      tomorrow = Time.now.tomorrow
      appointment = create(:appointment, start_date: Time.now, arm: @arm, name: "Visit 1", participant: @participant)
      patch :update, {
        id: appointment.id,
        field: 'start_date',
        appointment: attributes_for(:appointment, start_date: tomorrow.strftime("%F")),
        format: :js
      }
      expect(assigns(:appointment).start_date.strftime("%F")).to eq(tomorrow.strftime("%F"))
    end

    it "should save the completed date" do
      tomorrow = Time.now.tomorrow
      appointment = create(:appointment, start_date: Time.current, completed_date: Time.now, arm: @arm, name: "Visit 1", participant: @participant)
      put :update, {
        id: appointment.id,
        field: 'completed_date',
        appointment: attributes_for(:appointment, completed_date: tomorrow.strftime("%F")),
        format: :js
      }
      expect(assigns(:appointment).completed_date.strftime("%F")).to eq(tomorrow.strftime("%F"))
    end
  end
end
