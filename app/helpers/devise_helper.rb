module DeviseHelper
  def devise_error_messages!
    return '' if resource.errors.empty?

    content_tag(:div, class: "panel panel-danger") do
      concat(content_tag(:div, class: "panel-heading") do
        concat(content_tag(:h4, class: "panel-title") do
            # concat "#{pluralize(resource.errors.count, "error")} prohibited this #{resource.class.name.downcase} from being saved:"
            concat "#{pluralize(resource.errors.count, "error")} prohibited this #{resource.class.name.downcase} from being saved:"
        end)
      end)
      concat(content_tag(:div, class: "panel-body") do
        concat(content_tag(:ul) do
          resource.errors.full_messages.each do |msg|
              concat content_tag(:li, msg)
          end
        end)
      end)
    end
  end
end
