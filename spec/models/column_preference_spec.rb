require 'rails_helper'

RSpec.describe ColumnPreference, type: :model do
  let!(:identity) { create(:identity) }

  subject {
    ColumnPreference.new(
      identity: identity,
      column_name: 'month_year',
      visible: true
    )
  }

  it { is_expected.to belong_to(:identity) }
  it { is_expected.to validate_presence_of(:column_name) }
  it { is_expected.to validate_inclusion_of(:visible).in_array([true, false]) }
  it { is_expected.to validate_uniqueness_of(:column_name).scoped_to(:identity_id) }

  describe '.hidden' do
    it 'returrns only hidden column preferences' do
      visible_pref = ColumnPreference.create!(
        identity: identity,
        column_name: 'month_year',
        visible: true
      )

      hidden_pref = ColumnPreference.create!(
        identity: identity,
        column_name: 'quantity',
        visible: false
      )

      expect(ColumnPreference.hidden).to include(hidden_pref)
      expect(ColumnPreference.hidden).not_to include(visible_pref)
    end
  end
end
