require 'rails_helper'

RSpec.describe ParticipantsController do

  before :each do
    sign_in
    @protocol = create(:protocol)
    @participant = create(:participant, protocol_id: @protocol.id)
  end

  it "should delete a participant" do
    expect{
      delete :destroy, {
        protocol_id: @protocol.id,
        id: @participant.id,
        format: :js
      }
    }.to change(Participant, :count).by(-1)
  end

  it "should create a new participant" do
    expect{
      post :create, {
        protocol_id: @protocol.id,
        participant: attributes_for(:participant),
        format: :js
      }
    }.to change(Participant, :count).by(1)
  end

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

  it "should change a participant's arm" do 
    @arm = create(:arm, protocol_id: @protocol.id)
    put :update_arm, {
      protocol_id: @protocol.id,
      participant_id: @participant.id,
      arm: @arm,
      format: :js
    }
    @participant.reload
    expect(@participant.arm.id).to eq @arm.id
  end
end
