module StudyLevelActivitiesHelper

  def components_for_select components
    if components.empty?
      options_for_select(["This Service Has No Components"], disabled: "This Service Has No Components")
    else
      deleted_components = components.select{|c| c.deleted_at and c.selected } # deleted and selected
      visible_components = deleted_components + components.select{ |c| not c.deleted_at } # (deleted and selected) or not deleted
      options_from_collection_for_select( visible_components, 'id', 'component', selected: components.map{|c| c.id if c.selected}, disabled: deleted_components.map(&:id) )
    end
  end
end