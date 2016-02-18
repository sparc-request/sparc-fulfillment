module ReportHelper

  def truncated_options_from_collection_for_select(collection, value_method, text_method, selected = nil)
    options = collection.map do |element|
      [truncate_string_length(value_for_collection(element, text_method), 50), value_for_collection(element, value_method), option_html_attributes(element)]
    end
    selected, disabled = extract_selected_and_disabled(selected)
    select_deselect = {
      selected: extract_values_from_collection(collection, value_method, selected),
      disabled: extract_values_from_collection(collection, value_method, disabled)
    }

    truncated_options_for_select(options, select_deselect)
  end

  def truncated_options_for_select(container, selected = nil)
    return container if String === container

    selected, disabled = extract_selected_and_disabled(selected).map do | r |
       Array.wrap(r).map { |item| item.to_s }
    end

    container.map do |element|
      html_attributes = option_html_attributes(element)
      text, value = option_text_and_value(element).map { |item| item.to_s }
      selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
      disabled_attribute = ' disabled="disabled"' if disabled && option_value_selected?(value, disabled)
      %(<option class="truncate" value="#{ERB::Util.html_escape(value)}"#{selected_attribute}#{disabled_attribute}#{html_attributes}>#{ERB::Util.html_escape(text)}</option>)
    end.join("\n").html_safe
  end
end