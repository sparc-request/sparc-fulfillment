require 'rails_helper'

RSpec.describe DependentObjectImporter do

  it 'should respond_to #save_and_create_dependents' do
    arm                       = double('arm')
    dependent_object_importer = DependentObjectImporter.new(arm)

    expect(dependent_object_importer).to respond_to(:save_and_create_dependents)
  end
end
