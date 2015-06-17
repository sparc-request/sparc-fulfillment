require 'rails_helper'

RSpec.describe DocumentsController do

  render_views

  before :each do
    sign_in
    @line_item = create(:line_item, protocol: create(:protocol), service: create(:service))
    @document = create(:document, documentable_id: @line_item.id, documentable_type: 'LineItem')
  end

  describe 'GET #show' do

    it 'should render the document' do
      document = create(:document_with_csv_file)
      get :show, { id: document.id }
      expect(response.headers["Content-Type"]).to include("text/csv")
      expect(response.body).to eq("a, b, c")
    end
  end
end
