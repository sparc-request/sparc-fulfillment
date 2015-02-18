require 'rails_helper'

RSpec.describe ProjectRoleImporterJob do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/project_roles/1.json"

      ProjectRoleImporterJob.enqueue(1, callback_url)

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform' do

    before do
      @protocol     = create(:protocol, sparc_id: 3255)
      @callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/project_roles/1.json"
    end

    context 'create' do

      before do
        project_role_importer_job = ProjectRoleImporterJob.new(1, @callback_url, 'create')

        project_role_importer_job.perform
      end

      describe 'User creation' do

        it 'should create a User' do
          user = User.first

          expect(user).to be
          expect(user.first_name).to eq('Jennifer')
          expect(user.last_name).to eq('Zimmerman')
          expect(user.email).to eq('zimmerj@musc.edu')
        end
      end

      describe 'UserRole creation' do

        it 'should create a User' do
          user_role = UserRole.first

          expect(user_role).to be
          expect(user_role.user).to be_present
          expect(user_role.protocol).to be_present
          expect(user_role.rights).to be_present
          expect(user_role.role).to be_present
        end
      end

      describe 'API requests' do

        it 'should make requests to the objects callback_url', vcr: :localhost do
          # SPARC project_role request
          expect(a_request(:get, /\/v1\/project_roles\/1.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once

          # SPARC identity request
          expect(a_request(:get, /\/v1\/identities\/7.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once
        end
      end
    end

    context 'update' do

      before do
        @user                     = create(:user, email: 'zimmerj@musc.edu')
        @user_role                = create(:user_role,
                                            user: @user,
                                            protocol: @protocol,
                                            rights: 'rights',
                                            role: 'role',
                                            role_other: 'role_other')
        project_role_importer_job = ProjectRoleImporterJob.new(1, @callback_url, 'update')

        project_role_importer_job.perform
      end

      describe 'UserRole update' do

        it 'should update existing UserRole' do
          expect(@user_role.reload.rights).to eq('approve')
          expect(@user_role.reload.role).to eq('research-assistant-coordinator')
        end
      end

      describe 'API requests' do

        it 'should make requests to the objects callback_url', vcr: :localhost do
          # SPARC project_role request
          expect(a_request(:get, /\/v1\/project_roles\/1.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once

          # SPARC identity request
          expect(a_request(:get, /\/v1\/identities\/7.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once
        end
      end
    end

    context 'destroy' do

      before do
        @user                     = create(:user, email: 'zimmerj@musc.edu')
        @user_role                = create(:user_role,
                                            user: @user,
                                            protocol: @protocol,
                                            rights: 'rights',
                                            role: 'role',
                                            role_other: 'role_other')
        project_role_importer_job = ProjectRoleImporterJob.new(1, @callback_url, 'destroy')

        project_role_importer_job.perform
      end

      describe 'UserRole destroy' do

        it 'should destroy existing UserRole' do
          expect(UserRole.exists? @user_role.id)
        end
      end

      describe 'API requests' do

        it 'should make requests to the objects callback_url', vcr: :localhost do
          # SPARC project_role request
          expect(a_request(:get, /\/v1\/project_roles\/1.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once

          # SPARC identity request
          expect(a_request(:get, /\/v1\/identities\/7.json/).
            with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once
        end
      end
    end
  end
end
