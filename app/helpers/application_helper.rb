module ApplicationHelper

  def format_date(date)
    if date.present?
      date.strftime('%F')
    else
      ''
    end
  end

  def format_time(time)
    if time.present?
      time.strftime('%H:%M')
    else
      ''
    end
  end

  def hidden_class(val)
    :hidden if val == true
  end

  def pretty_tag(tag)
    tag.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
  end

  def body_class
    qualified_controller_name = controller.controller_path.gsub('/','-')

    "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name}"
  end

  ##Sets css bootstrap classes for rails flash message types##
  def twitterized_type(type)
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
end
