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

      it 'should create a document' do
        do_post
        expect(assigns(:document)).to be_an_instance_of Document
      end

      it "should not create a document without a title" do
        params = {report_type: "invoice_report", title: ""}
        do_post params
        expect(assigns(:errors).messages[:title]).to be
      end

      it 'should create a ReportJob ActiveJob' do
        expect(ReportJob).to receive(:perform_later).once
        do_post
      end

      def do_post params={report_type: "invoice_report", title: "Invoice Report 1", start_date: "06/01/2016", end_date: "06/02/2016", protocol_ids: [1], sort_by: 'Protocol ID', sort_order: 'ASC'}
        xhr :post, :create, params, format: :js
      end

    end
  end
end
