module ApplicationHelper
  def generate_history_text url
    begin
      h = Rails.application.routes.recognize_path(url)
      case h[:action]
      when 'index'
        ['All', h[:controller].humanize].join(' ')
      when 'show'
        klass = h[:controller].classify.constantize
        klass.title h[:id]
      else
        url
      end
    rescue Exception => e
      puts "#"*20
      puts e.message
      puts "#"*20
      return url
    end
  end

  def format_date date
    if date.present?
      # date.strftime('%F')
      date.strftime('%m/%d/%Y')
    else
      ''
    end
  end

  def format_datetime date
    if date.present?
      date.strftime('%F %H:%M')
    else
      ''
    end
  end

  def display_cost cost
    dollars = (cost / 100.0) rescue nil
    dollar, cent = dollars.to_s.split('.')
    dollars_formatted = "#{dollar}.#{cent[0..1]}".to_f

    number_to_currency(dollars_formatted, seperator: ",")
  end

  def hidden_class val
    :hidden if val
  end

  def disabled_class val
    :disabled if val
  end

  # Class a div containing a disabled button so that
  # you can attach an onclick listener to the div
  # to alert the user why button is disabled.
  def contains_disabled_class val
    :contains_disabled if val
  end

  def pretty_tag(tag)
    tag.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
  end

  def body_class
    qualified_controller_name = controller.controller_path.gsub('/','-')

    "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name}"
  end

  ##Sets css bootstrap classes for rails flash message types##
  def twitterized_type type
    case type.to_sym
      when :alert
        "alert-danger"
      when :error
        "alert-danger"
      when :notice
        "alert-info"
      when :success
        "alert-success"
      else
        type.to_s
    end
  end

  def truncated_formatter data
    [
      "<span data-toggle='tooltip' data-placement='left' data-animation='false' title='#{data}'>",
      "#{data}",
      "</span>"
    ].join ""
  end

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def back_link url
    url.to_s + "?back=true" # handles root url as well (nil)
  end

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

  def truncate_string_length(s, max=70, elided = ' ...')
    #truncates string to max # of characters then adds elipsis
    if s.present?
      s.match( /(.{1,#{max}})(?:\s|\z)/ )[1].tap do |res|
        res << elided unless res.length == s.length
      end
    else
      ""
    end
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
