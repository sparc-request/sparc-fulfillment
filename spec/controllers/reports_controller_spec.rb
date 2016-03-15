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

  describe 'GET #update_dropdown' do
    
    it 'should return an array of protocols' do
      institution_organization = create(:organization_institution)

      provider_organization = create(:provider_with_child_organizations)
      provider_organization.update_attribute(:parent_id, institution_organization.id)

      program_organization = create(:program_with_child_organizations)
      program_organization.update_attribute(:parent_id, provider_organization.id)

      core_organization = create(:organization_with_child_organizations)
      core_organization.update_attribute(:parent_id, program_organization.id)

      program_sub_service_request = create(:sub_service_request, organization: program_organization)
      program_protocol            = create(:protocol, sub_service_request: program_sub_service_request)

      provider_sub_service_request = create(:sub_service_request, organization: provider_organization)
      provider_protocol            = create(:protocol, sub_service_request: provider_sub_service_request)

      core_sub_service_request = create(:sub_service_request, organization: core_organization)
      core_protocol            = create(:protocol, sub_service_request: core_sub_service_request)

      organization_ids = [provider_organization.id, program_organization.id, core_organization.id]

      
      xhr :post, :update_dropdown, org_ids: organization_ids 

      expect(assigns(:protocols)).to eq([provider_protocol, program_protocol, core_protocol])
    end
  end
end
