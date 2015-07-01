module StudyLevelActivitiesHelper

  def components_for_select components
    if components.empty?
      options_for_select(["This Service Has No Components"], disabled: "This Service Has No Components")
    else
      options_from_collection_for_select(components, 'id', 'component', selected: components.map{|c| c.id if c.selected}, disabled: components.map{|c| c.id if c.deleted_at})
    end
  end
end