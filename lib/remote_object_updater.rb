class RemoteObjectUpdater

  def initialize(parsed_json, object)
    @parsed_json  = parsed_json
    @object       = object
  end

  def import!
    object_class      = @object.class.to_s.underscore
    object_attributes = filter(@parsed_json[object_class], object_class)

    @object.update_attributes object_attributes
  end

  private

  def filter(json_in, klass)
    json_out              = Hash.new
    json_object_all_keys  = class_attribute_filter(klass)

    json_in.reject { |key, value| !json_object_all_keys.include?(key) }.
      each { |key, value| json_out.merge! Hash[key, value] }

    json_out
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
