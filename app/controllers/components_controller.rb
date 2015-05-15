class ComponentsController < ApplicationController

  def update
    if params[:components] == ""
      component_ids_to_select = []
    else
      component_ids_to_select = params[:components].reject(&:empty?).map(&:to_i)
    end

    line_item_components = Component.where(composable_id: params[:line_item_id], composable_type: "LineItem")
    line_item_components.update_all(selected: false)
    component_ids_to_select.each{ |id| line_item_components.find(id).update(selected: true)}
    flash[:success] = t(:flash_messages)[:line_item][:updated]
  end
end
