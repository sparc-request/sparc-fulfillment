class RemoteObjectNormalizer

  def initialize(local_object_class, remote_object_attributes)
    @local_object_class       = local_object_class
    @remote_object_attributes = remote_object_attributes
  end

  def normalize!
    filter(@remote_object_attributes, @local_object_class)
  end

  private

  def filter(remote_object_attributes, klass)
    attributes                  = Hash.new
    local_object_attribute_keys = class_attribute_filter(klass)

    remote_object_attributes.reject { |key, value| !local_object_attribute_keys.include?(key) }.
      each { |key, value| attributes.merge! Hash[key, value] }

    attributes
  end

  def class_attribute_filter(klass)
    klazz       = klass.classify.constantize
    instance    = klazz.new
    attributes  = instance.attributes.keys

    attributes.delete_if { |attribute| universal_attribute_filter.include?(attribute) }
  end

  def universal_attribute_filter
    ['id', 'created_at', 'updated_at', 'deleted_at'].freeze
  end
end
