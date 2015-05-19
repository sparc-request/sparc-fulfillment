require 'rails_helper'

RSpec.describe UserRoleImporterJob, type: :job do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/project_roles/1.json"

      UserRoleImporterJob.enqueue(1, callback_url, 'create')

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform', sparc_api: :get_project_role_1 do

    before do
      Protocol.skip_callback :save, :after, :update_faye

      @protocol     = create(:protocol, sparc_id: 3255)

      Protocol.set_callback :save, :after, :update_faye

      @callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/project_roles/1.json"
    end

    context 'create' do

      before do
        project_role_importer_job = UserRoleImporterJob.new(1, @callback_url, 'create')

        project_role_importer_job.perform
      end

      describe 'User creation' do

        it 'should create a User' do
          identity = Identity.first

          expect(identity).to be
          expect(identity.first_name).to eq('Jennifer')
          expect(identity.last_name).to eq('Zimmerman')
          expect(identity.email).to eq('zimmerj@musc.edu')
        end
      end

      describe 'UserRole creation' do

        it 'should create a User' do
          identity_role = IdentityRole.first

          expect(identity_role).to be
          expect(identity_role.identity).to be_present
          expect(identity_role.protocol).to be_present
          expect(identity_role.rights).to be_present
          expect(identity_role.role).to be_present
        end
      end

      describe 'API requests' do

        it 'should make requests to the objects callback_url' do
          # SPARC project_role request
          expect(a_request(:get, /\/v1\/project_roles\/1.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once

          # SPARC identity request
          expect(a_request(:get, /\/v1\/identities\/7.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once
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
        @user                     = create(:user, email: 'zimmerj@musc.edu')
        @identity_role                = create(:identity_role,
                                            user: @user,
                                            protocol: @protocol,
                                            rights: 'rights',
                                            role: 'role',
                                            role_other: 'role_other')
        project_role_importer_job = UserRoleImporterJob.new(1, @callback_url, 'update')

        project_role_importer_job.perform
      end

      describe 'UserRole update' do

        it 'should update existing UserRole' do
          expect(@identity_role.reload.rights).to eq('approve')
          expect(@identity_role.reload.role).to eq('research-assistant-coordinator')
        end
      end

      describe 'API requests' do

        it 'should make requests to the objects callback_url' do
          # SPARC project_role request
          expect(a_request(:get, /\/v1\/project_roles\/1.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once

          # SPARC identity request
          expect(a_request(:get, /\/v1\/identities\/7.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once
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
        @user                     = create(:user, email: 'zimmerj@musc.edu')
        @identity_role                = create(:identity_role,
                                            user: @user,
                                            protocol: @protocol,
                                            rights: 'rights',
                                            role: 'role',
                                            role_other: 'role_other')
        project_role_importer_job = UserRoleImporterJob.new(1, @callback_url, 'destroy')

        project_role_importer_job.perform
      end

      describe 'UserRole destroy' do

        it 'should destroy existing UserRole' do
          expect(UserRole.exists? @identity_role.id)
        end
      end

      describe 'API requests' do

        it 'should make requests to the objects callback_url' do
          # SPARC project_role request
          expect(a_request(:get, /\/v1\/project_roles\/1.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once

          # SPARC identity request
          expect(a_request(:get, /\/v1\/identities\/7.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once
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
