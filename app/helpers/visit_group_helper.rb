module VisitGroupHelper

  def vg_add_as_last_option arm
    content_tag(:option, "Add as last", value: arm.visit_groups.size)
  end
end
