class DependentObjectImporter

  attr_accessor :object

  def initialize(object)
    @object = object
  end

  def save_and_create_dependents
    if object.save
      create_dependents
    end
    object.persisted?
  end
end
