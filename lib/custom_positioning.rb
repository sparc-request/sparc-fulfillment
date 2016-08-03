module CustomPositioning
  def insertion_name
    "Insert before "+name+(visit_group && visit_group.day ? " (Day #{visit_group.day})" : "")
  end
end
