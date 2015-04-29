class ComponentsController < ApplicationController

  before_action :find_component, only: [:update]

  def update
    @component.update_attributes(component_params)

    flash[:success] = t(:flash_messages)[:fulfillment][:updated] if component_params[:component]
    flash[:success] = t(:flash_messages)[:line_item][:updated] if component_params[:selected]
  end

  private

  def component_params
    @component_params = params.require(:component).permit(:component, :selected)
  end

  def find_component
    @component = Component.where(id: params[:id]).first
  end
end