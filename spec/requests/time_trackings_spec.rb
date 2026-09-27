require 'rails_helper'

RSpec.describe "TimeTrackings", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/time_trackings"
      expect(response).to have_http_status(:success)
    end
  end

end
