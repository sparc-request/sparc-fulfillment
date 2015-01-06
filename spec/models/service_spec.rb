require 'rails_helper'

RSpec.describe Service, type: :model do

  it { should have_many(:line_items).dependent(:destroy) }

  context 'class methods' do

    describe '#delete' do

      it 'should not permanently delete the record' do
        service = create(:service)

        service.delete

        expect(service.persisted?).to be
      end
    end
  end
end
