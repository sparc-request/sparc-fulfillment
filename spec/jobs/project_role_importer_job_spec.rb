require 'rails_helper'

RSpec.describe ProjectRoleImporterJob, type: :job do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      ProjectRoleImporterJob.enqueue(1, "http://www.google.com", 'create')

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform', sparc_api: :get_project_role_1 do

    before do
      Protocol.skip_callback :save, :after, :update_faye

      @protocol   = create(:protocol, sparc_id: 3255)
      @identity   = create(:identity, email: "email@musc.edu")
      allow(Identity).to receive(:find).and_return(@identity)

      Protocol.set_callback :save, :after, :update_faye

      @callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/project_roles/1.json"
    end

    context 'create' do

      before do
        project_role_importer_job = ProjectRoleImporterJob.new(1, @callback_url, 'create')

        project_role_importer_job.perform
      end

      describe 'ProjectRole creation' do

        it 'should create a ProjectRole' do
          project_role = ProjectRole.first

          expect(project_role).to be
          expect(project_role.identity).to be_present
          expect(project_role.protocol).to be_present
          expect(project_role.rights).to be_present
          expect(project_role.role).to be_present
        end
      end

      describe 'API requests' do

        it 'should make requests to the objects callback_url' do
          expect(a_request(:get, /\/v1\/project_roles\/1.json/)).to have_been_made.once
        end
      end

      describe 'Faye' do

        it "should not POST to the Faye server" do
          expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/)).to_not have_been_made
        end
      end
    end

    context 'update' do

      before do
        @project_role = create(:project_role,
                                identity: @identity,
                                protocol: @protocol,
                                role: 'role',
                                role_other: 'role_other')
        project_role_importer_job = ProjectRoleImporterJob.new(1, @callback_url, 'update')

        project_role_importer_job.perform
      end

      describe 'ProjectRole update' do

        it 'should update existing ProjectRole' do
          expect(@project_role.reload.rights).to eq('approve')
          expect(@project_role.reload.role).to eq('research-assistant-coordinator')
        end
      end

      describe 'API requests' do

        it 'should make requests to the objects callback_url' do
          expect(a_request(:get, /\/v1\/project_roles\/1.json/)).to have_been_made.once
        end
      end

      describe 'Faye' do

        it "should not POST to the Faye server" do
          expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/)).to_not have_been_made
        end
      end
    end

    context 'destroy' do

      before do
        @project_role = create(:project_role,
                                identity: @identity,
                                protocol: @protocol,
                                role: 'role',
                                role_other: 'role_other')
        project_role_importer_job = ProjectRoleImporterJob.new(1, @callback_url, 'destroy')

        project_role_importer_job.perform
      end

      describe 'ProjectRole destroy' do

        it 'should destroy existing ProjectRole' do
          expect(ProjectRole.exists? @project_role.id).to_not be
        end
      end

      describe 'API requests' do

        it 'should make requests to the objects callback_url' do
          expect(a_request(:get, /\/v1\/project_roles\/1\.json/)).to have_been_made.once
        end
      end

      describe 'Faye' do

        it "should not POST to the Faye server" do
          expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/)).to_not have_been_made
        end
      end
    end
  end
end
