class ArmsController < ApplicationController

  respond_to :json, :html
  
  def change
    arm = Arm.find(params[:id])
    respond_with arm.visit_groups
  end
end
