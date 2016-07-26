require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do

  login_user

  describe 'POST #create' do

    context 'success' do

      before do
        identity  = Identity.first
        document  = Rack::Test::UploadedFile.new(File.join('db', 'fixtures', 'test_document.txt'),'txt/plain')
        params    = { document: { title: 'test_document', documentable_id: identity.id, documentable_type: 'Identity', document: document } }

        xhr :post, :create, params, format: :js
      end

      it 'should render with status: :success' do
        expect(response).to be_success
      end

      it 'should persist a Document object to database' do
        expect(assigns(:document)).to be_persisted
      end

      it 'should persist a file to the filesystem' do
        expect(File.exists?(assigns(:document).path)).to be
      end
    end

    context 'failure' do

      it 'should assign an error message to @error' do
        identity  = Identity.first
        params    = { document: { documentable_id: identity.id, documentable_type: 'Identity', document: nil } }

        xhr :post, :create, params, format: :js

        expect(assigns(:error)).to be
      end
    end
  end
end
