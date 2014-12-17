module DeviseHelper
  def devise_error_messages!
    return '' if resource.errors.empty?

    content_tag(:div, class: "alert alert-danger") do
      resource.errors.full_messages.each do |msg|
        concat content_tag(:p, msg)
      end
    end

  end
end
