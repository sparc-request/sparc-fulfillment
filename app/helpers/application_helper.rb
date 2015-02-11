module ApplicationHelper

  def format_date(date)
    if date.present?
      date.strftime('%x')
    else
      ''
    end
  end

  def pretty_tag(tag)
    tag.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
  end

  def body_class
    qualified_controller_name = controller.controller_path.gsub('/','-')

    "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name}"
  end

  # Faye pub/sub methods
  def broadcast(channel, &block)
    message = {:channel => channel, :data => capture(&block)}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
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
