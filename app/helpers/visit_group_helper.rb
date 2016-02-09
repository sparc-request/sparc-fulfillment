module VisitGroupHelper

  def add_as_last_option arm
    content_tag(:option, "Add as last", value: arm.visit_groups.last.position + 1)
  end
end