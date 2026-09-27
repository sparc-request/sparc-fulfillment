require 'rails_helper'

RSpec.describe "TimeTrackings", type: :request do
  let!(:identity) { create(:identity) }

  before do
    sign_in identity
  end

  describe "GET /index" do
    it "returns http success" do
      get "/time_trackings"
      expect(response).to have_http_status(:success)
    end
  end

end
