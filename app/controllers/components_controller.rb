class ComponentsController < ApplicationController

  before_action :find_component, only: [:update]

  def update
    @component.update_attributes(component_params)
  end

  private

  def component_params
    @component_params = params.require(:component).permit(:selected)
  end

  def find_component
    @component = Component.where(id: params[:id]).first
  end
end