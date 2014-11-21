require 'rails_helper'

RSpec.describe 'Index spec', type: :feature, js: true do

  before { visit protocols_path }

  let!(:protocol1) { FactoryGirl.create(:)}
  describe 'status select' do


  end
end