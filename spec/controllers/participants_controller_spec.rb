require 'rails_helper'

RSpec.describe ParticipantsController do

  before :each do
    sign_in
    @protocol = create(:protocol)
    @participant = create(:participant, protocol_id: @protocol.id)
  end

  describe "GET #index" do
    it "should get participants" do
      get :index, {
        protocol_id: @protocol.id,
        format: :json
      }
      expect(assigns(:participants)).to eq([@participant])
    end
  end

  describe "GET #new" do
    it "should instantiate a new participant" do
      xhr :get, :new, {
        protocol_id: @protocol.id,
        format: :js
      }
      expect(assigns(:participant)).to be_a_new(Participant)
    end
  end

  describe "POST #create" do
    it "should create a new participant" do
      attributes = @participant.attributes
      bad_attributes = ["date_of_birth","id", "deleted_at", "created_at", "updated_at", "total_cost"]
      attributes.delete_if {|key| bad_attributes.include?(key)}
      attributes[:date_of_birth] = "09-10-2015"
      expect{
        post :create, {
          participant: attributes,
          format: :js
        }
      }.to change(Participant, :count).by(1)
    end
  end

  describe "GET #edit" do
    it "should select an instantiated participant" do
      xhr :get, :edit, {
        protocol_id: @protocol.id,
        id: @participant.id,
        format: :js
      }
      expect(assigns(:participant)).to eq(@participant)
    end
  end

  describe "PUT #update" do
    it "should update a participant" do
      put :update, {
        protocol_id: @protocol.id,
        id: @participant.id,
        participant: attributes_for(:participant, first_name: 'Chick'),
        format: :js
      }
      @participant.reload
      expect(@participant.first_name).to eq 'Chick'
    end
  end

  describe "DELETE #destroy" do
    it "should delete a participant" do
      expect{
        delete :destroy, {
          protocol_id: @protocol.id,
          id: @participant.id,
          format: :js
        }
      }.to change(Participant, :count).by(-1)
    end
  end

  describe "GET #edit_arm" do
    it "should find the participant" do
      xhr :get, :edit_arm, {
        protocol_id: @protocol.id,
        participant_id: @participant.id,
        format: :js
      }
      expect(assigns(:participant)).to eq(@participant)
    end
  end

  describe "PUT #update_arm" do
    it "should change a participant's arm" do
      @arm = create(:arm, protocol_id: @protocol.id)
      put :update_arm, {
        protocol_id: @protocol.id,
        participant_id: @participant.id,
        participant: {arm_id: @arm.id},
        format: :js
      }
      @participant.reload
      expect(@participant.arm_id).to eq @arm.id
    end
  end

  describe "GET #details" do
    it "should select an instantiated participant" do
      xhr :get, :details, {
        protocol_id: @protocol.id,
        participant_id: @participant.id,
        format: :js
      }
      expect(assigns(:participant)).to eq(@participant)
    end
  end
end
