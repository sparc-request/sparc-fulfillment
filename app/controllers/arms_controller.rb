class ArmsController < ApplicationController
  respond_to :json, :html
  def change
    arm = Arm.find(params[:id])
    respond_with arm.visit_groups
  end

  def new
    @protocol = Protocol.find(params[:id])
    @arm = Arm.new(protocol: @protocol)
  end

  def create
    @arm = Arm.new(arm_params)
    # @arm.protocol_id = params[:protocol_id]
    @arm.save
    flash[:success] = "Arm Created"
  end

  def arm_params
    params.require(:arm).permit(:protocol_id, :name, :visit_count, :subject_count)
  end
end
