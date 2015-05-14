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

          it 'should create a struct:ProtocolImporterJob delayed job' do
            expect(Delayed::Job.where("handler LIKE '%struct:ProtocolImporterJob%'").one?).to be
          end
        end
      end

      context 'ProjectRole' do

        context 'create action' do

          before do
            params = { notification: attributes_for(:notification_project_role_create) }

            sparc_sends_notification_post(params)
          end

          it 'should create a UserRoleImporterJob delayed job' do
            expect(Delayed::Job.where("handler LIKE '%struct:UserRoleImporterJob%'").one?).to be
          end
        end
      end
    end
  end
end
