class ComponentsController < ApplicationController

  def update
    line_item = LineItem.find(params[:line_item_id])
    new_component_ids = params[:components] == "" ? [] : params[:components].reject(&:empty?).map(&:to_i)
    old_component_ids = line_item.components.where(selected: true).map(&:id)

    to_select = new_component_ids - old_component_ids
    to_select.each do |id|
      component = Component.find(id)
      component.update_attributes(selected: true)
      comment = "Component: #{component.component} indicated"
      line_item.notes.create(kind: 'log', comment: comment, identity: current_identity)
    end

    to_deselect = old_component_ids - new_component_ids
    to_deselect.each do |id|
      component = Component.find(id)
      component.update_attributes(selected: false)
      comment = "Component: #{component.component} no longer indicated"
      line_item.notes.create(kind: 'log', comment: comment, identity: current_identity)
    end

    flash[:success] = t(:line_item)[:flash_messages][:updated]
  end
end
