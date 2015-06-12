require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do

  render_views

  login_user

  describe 'GET #show' do

    context 'Document is accessible by Identity' do

      it 'should render the document' do
        protocol  = create(:protocol)
        service   = create(:service)
        line_item = create(:line_item, protocol: protocol, service: service)
        document  = create(:document_with_csv_file,
                            documentable_id: line_item.id,
                            documentable_type: 'LineItem')

        get :show, { id: document.id }

        expect(response.headers["Content-Type"]).to include("text/csv")
        expect(response.body).to eq("a, b, c")
      end
    end

    context 'Document is not accessible by Identity' do

      it 'should not render the document' do
        identity  = create(:identity)
        document  = create(:document_with_csv_file,
                            documentable_id: identity.id,
                            documentable_type: 'Identity')

        get :show, { id: document.id }

        expect(response.body).to eq("")
      end
    end
  end
end
