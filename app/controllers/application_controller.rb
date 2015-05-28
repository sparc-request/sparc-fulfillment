class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :authenticate_identity!
  before_filter :last_page
  around_filter :set_time_zone, if: :identity_signed_in?

  def set_time_zone(&block)
    time_zone = current_identity.time_zone
    Time.use_zone(time_zone, &block)
  end

  def authorize_identity protocol_id
    unless current_identity.protocols.map(&:id).include? protocol_id.to_i
      flash[:alert] = t(:protocol)[:flash_messages][:unauthorized]
      redirect_to root_path
    end
  end

  private

  def last_page
    session[:last_page] = request.env['HTTP_REFERER']
  end
end
