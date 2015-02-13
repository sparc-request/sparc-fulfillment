require 'rails_helper'

RSpec.describe NotificationDispatcher, type: :request do

  describe '#dispatch', delay: true do

    context 'indirectly importable class' do

      context 'SubServiceRequest' do

        context 'update action' do

          before do
            params = { notification: attributes_for(:notification_sub_service_request_update) }

            sparc_sends_notification_post(params)
          end

          it 'should create a struct:SubServiceRequestImporterJob delayed job' do
            expect(Delayed::Job.where("handler LIKE '%struct:SubServiceRequestImporterJob%'").one?).to be
          end
        end
      end

      context 'ProjectRole' do

        context 'create action' do

          before do
            params = { notification: attributes_for(:notification_project_role_create) }

            sparc_sends_notification_post(params)
          end

          it 'should create a ProjectRoleImporterJob delayed job' do
            expect(Delayed::Job.where("handler LIKE '%struct:ProjectRoleImporterJob%'").one?).to be
          end
        end
      end
    end

    context 'directly imnportable class' do

      context 'notification of create' do

        before do
          @object = build(:service, sparc_id: 1)
          @params = { notification: attributes_for(:notification_service_create) }
        end

        context 'object not present' do

          before { sparc_sends_notification_post(@params) }

          it 'should create an object with a :sparc_id' do
            expected_service = Service.where(sparc_id: 1).first

            expect(expected_service).to be
          end

          it 'should create a RemoteObjectUpdaterJob delayed job' do
            expect(Delayed::Job.where("handler LIKE '%RemoteObjectUpdaterJob%'").one?).to be
          end
        end

        context 'object already present' do

          before do
            @object.save
            sparc_sends_notification_post(@params)
          end

          it 'should not create a new object' do
            sparc_sends_notification_post(@params)

            expect(Service.count).to eq(1)
          end

          it 'should not create a RemoteObjectUpdaterJob delayed job' do
            expect(Delayed::Job.count).to eq(0)
          end
        end
      end

      context 'notification of update' do

        before do
          @object = create(:service, sparc_id: 1)
          @params = { notification: attributes_for(:notification_service_update) }
        end

        context 'object somehow not present' do

          before { sparc_sends_notification_post(@params) }

          it 'should create an object' do
            expect(Service.count).to eq(1)
          end

          it 'should create a RemoteObjectUpdaterJob delayed job' do
            expect(Delayed::Job.where("handler LIKE '%RemoteObjectUpdaterJob%'").one?).to be
          end
        end

        context 'object present' do

          before do
            @object.save
            sparc_sends_notification_post(@params)
          end

          it 'should not create a new object' do
            sparc_sends_notification_post(@params)

            expect(Service.count).to eq(1)
          end

          it 'should create a RemoteObjectUpdaterJob delayed job' do
            expect(Delayed::Job.where("handler LIKE '%RemoteObjectUpdaterJob%'").one?).to be
          end
        end
      end
    end
  end
end
