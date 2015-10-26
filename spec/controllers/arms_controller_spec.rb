require 'rails_helper'

RSpec.describe ArmsController do

  before :each do
    sign_in
    @protocol = create(:protocol)
    @arm = create(:arm, protocol_id: @protocol.id)
  end

  describe "GET #new" do
    it "should instantiate a new arm" do
      xhr :get, :new, {
        protocol_id: @protocol.id,
        format: :js
      }
      expect(assigns(:arm)).to be_a_new(Arm)
    end
  end

  describe "POST #create" do
    it "should save a new arm if valid" do
      expect{
        post :create, {
          protocol_id: @protocol.id,
          arm: attributes_for(:arm),
          format: :js
        }
      }.to change(Arm, :count).by(1)
    end

    it "should not save a new arm if invalid" do
      expect{
        post :create, {
          protocol_id: @protocol.id,
          arm: attributes_for(:arm, subject_count: 'A'),
          format: :js
        }
      }.not_to change(Arm, :count)
    end
  end

  describe "DELETE #destroy", delay: false do
    it "should delete the arm" do
      @new_arm = create(:arm, protocol_id: @protocol.id) #more than one arm
      expect{
        delete :destroy, {
          protocol_id: @protocol.id,
          id: @arm.id,
          format: :js
        }
      }.to change(Arm, :count).by(-1)
    end

    it "should not delete the arm if last arm" do
      expect{
        delete :destroy, {
          protocol_id: @protocol.id,
          id: @arm.id,
          format: :js
        }
      }.not_to change(Arm, :count)
    end

    it "should not delete the arm if last arm" do
      create(:procedure_complete, arm: @arm)
      expect{
        delete :destroy, {
          protocol_id: @protocol.id,
          id: @arm.id,
          format: :js
        }
      }.not_to change(Arm, :count)
    end
  end

  describe "POST #update" do

    it "should update the arm" do
      post :update, {
        id: @arm.id,
        arm: @arm.attributes.merge({"name" => "BABOOM~*"}),
        format: :js
      }
      expect(assigns(:arm)).to have_attributes(name: "BABOOM~*")
    end
  end
end
