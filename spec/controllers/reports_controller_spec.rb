require 'rails_helper'

RSpec.describe ReportsController, type: :controller do

  login_user

  describe "POST #create" do

    context 'format: :js' do

      before :each do
        create(:protocol)
      end

      it 'should respond with: :success' do
        do_post
        expect(response).to be_success
      end

      it 'should create a document', delay: true do
        do_post
        expect(assigns(:document)).to be_an_instance_of Document
      end

      it "should not create a document without a title", delay: true do
        params = {report_type: "invoice_report", title: ""}
        do_post params
        expect(assigns(:errors).messages[:title]).to be
      end

      it 'should create a ReportJob ActiveJob' do
        expect { do_post }.to enqueue_a(ReportJob)
      end

      def do_post params = { report_type: "invoice_report", title: "Invoice Report 1", start_date: (Time.now - 1.day).to_s, end_date: Time.now.to_s, protocol_ids: [1] }
        xhr :post, :create, params, format: :js
      end

    end
  end
end
