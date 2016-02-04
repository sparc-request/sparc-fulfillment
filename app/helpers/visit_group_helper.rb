module VisitGroupHelper

  def add_as_last_option
    content_tag(:option, "Add as last", value: -1)
  end
end