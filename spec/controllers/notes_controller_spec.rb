require 'rails_helper'

RSpec.describe NotesController do

  before :each do
    @user = create(:user)
    @procedure = create(:procedure)
    sign_in @user
  end

  describe "GET #index" do
    it "should assign procedure" do
      xhr :get, :index, {
        procedure_id: @procedure.id,
        format: :js
      }
      expect(assigns(:procedure)).to eq(@procedure)
    end
  end

  describe "GET #new" do
    it "should instantiate a new note" do
      xhr :get, :new, {
        procedure_id: @procedure.id,
        format: :js
      }
      expect(assigns(:note)).to be_a_new(Note)
    end
  end

  describe "POST #create" do
    it "should create a new note" do
      expect{
        post :create, {
          procedure_id: @procedure.id,
          note: {comment: "okay"},
          format: :js
        }
      }.to change(Note, :count).by(1)
      expect(assigns(:note)).to have_attributes(comment: "okay")
    end
  end
end