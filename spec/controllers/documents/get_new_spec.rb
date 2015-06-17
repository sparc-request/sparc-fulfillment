require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do

  login_user

  describe 'GET #new' do

    context 'format: :js' do

      it 'should assign a new Document' do
        identity  = Identity.first
        params    = { document: { documentable_id: identity.id, documentable_type: 'Identity' }}

        xhr :get, :new, params, format: :js

        expect(assigns(:document)).to be_a_new(Document)
      end
    end
  end
end
