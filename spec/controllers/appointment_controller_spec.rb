require 'rails_helper'

RSpec.describe AppointmentsController do
  before :each do
    @user = create(:user)
    sign_in @user
    @protocol = create(:protocol_imported_from_sparc)
    @service = create(:service)
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

  describe "PATCH #completed_date" do
    it "should set the completed date if one doesn't exist" do
      today = Time.current.strftime("%F")
      appointment = create(:appointment, completed_date: nil)
      expect(appointment.completed_date).to eq(nil)
      patch :completed_date, {
        id: appointment.id,
        format: :js
      }
      expect(assigns(:appointment).start_date.strftime("%F")).to eq(today)
    end

    it "should change the completed date to the new date" do
      tomorrow = Time.now.tomorrow
      appointment = create(:appointment, completed_date: Time.now)
      patch :completed_date, {
        id: appointment.id,
        new_date: (tomorrow.to_i)*1000, #expects milliseconds
        format: :js
      }
      expect(assigns(:appointment).completed_date.strftime("%F")).to eq(tomorrow.strftime("%F"))
    end

    it "should change the completed date to the start date if the completed date is nil and the start date is in the future" do
      appointment = create(:appointment, completed_date: nil, start_date: Time.now.tomorrow)
      expect(appointment.completed_date).to eq(nil)
      patch :completed_date, {
        id: appointment.id,
        format: :js
      }
      expect(assigns(:appointment).completed_date.strftime("%F")).to eq(assigns(:appointment).start_date.strftime("%F"))
    end
  end

  describe "PATCH #start_date" do
    it "should set the start date if one doesn't exist" do
      today = Time.current.strftime("%F")
      appointment = create(:appointment, start_date: nil)
      expect(appointment.start_date).to eq(nil)
      patch :start_date, {
        id: appointment.id,
        format: :js
      }
      expect(assigns(:appointment).start_date.strftime("%F")).to eq(today)
    end

    it "should change the start date to the new date" do
      tomorrow = Time.now.tomorrow
      appointment = create(:appointment, start_date: Time.now)
      patch :start_date, {
        id: appointment.id,
        new_date: (tomorrow.to_i)*1000, #expects milliseconds
        format: :js
      }
      expect(assigns(:appointment).start_date.strftime("%F")).to eq(tomorrow.strftime("%F"))
    end
  end
end
