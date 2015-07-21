require 'rails_helper'

RSpec.describe ReportsController, type: :controller do

  login_user

  describe "POST #create" do

    context 'format: :js' do

      it 'should respond with: :success' do
        do_post
        expect(response).to be_success
      end

      it 'should create a document', delay: true do
        do_post
        expect(Document.count).to eq(1)
      end

      it "should not create a document without a title", delay: true do
        document_params = {document:{title: ""}}
        do_post document_params
        expect(Document.count).to eq(0)
      end

      it 'should create a ReportJob ActiveJob' do
        expect { do_post }.to enqueue_a(ReportJob)
      end

      def do_post document_params={ document:{title: "Test title" }}
        xhr :post, :create, document_params, format: :js
      end

    end
  end
end
