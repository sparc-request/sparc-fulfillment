module CustomPositioning
  def insertion_name
    "Insert before "+self.name+(self.day ? " (Day #{self.day})" : "")
  end
end
