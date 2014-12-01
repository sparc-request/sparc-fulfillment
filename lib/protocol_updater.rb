class ProtocolUpdater

  def initialize(json, protocol_id)
    @json         = json
    @protocol_id  = protocol_id
  end

  def import!
    protocol_as_json = filter(parsed_json, 'protocol')

    protocol.update_attributes protocol_as_json
  end

  private

  def filter(json_in, klass)
    json_out                    = Hash.new
    json_object_attributes_keys = class_attribute_filter(klass)
    json_object_reflection_keys = class_reflections_filter(klass)
    json_object_all_keys        = [class_reflections_filter(klass), class_attribute_filter(klass)].flatten

    json_in.reject { |key, value| !json_object_all_keys.include?(key) }.
      each { |key, value|
        if value.is_a?(Array)
          object_array = value.map { |hash| filter(hash, key) }

          json_out.merge! Hash["#{key}_attributes", object_array]
        else
          json_out.merge! Hash[key, value]
        end
      }

    json_out
  end

  def class_attribute_filter(klass)
    klazz       = klass.classify.constantize
    instance    = klazz.new
    attributes  = instance.attributes.keys

    attributes.delete_if { |attribute| universal_attribute_filter.include?(attribute) }
  end

  def class_reflections_filter(klass)
    klass.classify.constantize.reflections.keys.map(&:to_s)
  end

  def universal_attribute_filter
    ['id', 'created_at', 'updated_at', 'deleted_at']
  end

  def parsed_json
    Yajl::Parser.parse @json
  end

  def protocol
    @protocol ||= Protocol.find @protocol_id
  end
end
