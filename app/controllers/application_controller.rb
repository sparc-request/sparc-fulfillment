class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :authenticate_identity!
  before_filter :last_page
  around_filter :set_time_zone, if: :identity_signed_in?
  before_filter :push_user_to_gon, if: :identity_signed_in?

  def set_time_zone(&block)
    time_zone = current_identity.time_zone
    Time.use_zone(time_zone, &block)
  end

  def authorize_protocol
    unless current_identity.protocols.include? @protocol
      flash[:alert] = t(:protocol)[:flash_messages][:unauthorized]
      redirect_to root_path
    end
  end

  def user_for_paper_trail
    identity_signed_in? ? current_identity.id : 'Unauthenticated User'
  end

  def push_user_to_gon
    gon.push({current_identity_id: current_identity.id})
  end

  private

  def last_page
    session[:last_page] = request.env['HTTP_REFERER']
  end
end
