module CustomPositioning
  def insertion_name
  	visit_group = self.visit_group
  	"Insert before "+visit_group.name+(visit_group.day ? " (Day #{visit_group.day})" : "")
  end
end
