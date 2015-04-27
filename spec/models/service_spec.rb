require 'rails_helper'

RSpec.describe Service, type: :model do

  it { is_expected.to have_many(:line_items).dependent(:destroy) }
  it { is_expected.to have_many(:components) }

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
