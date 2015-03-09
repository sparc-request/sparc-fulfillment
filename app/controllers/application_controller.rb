class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  around_filter :set_time_zone, if: :user_signed_in?

  def set_time_zone(&block)
    time_zone = current_user.time_zone
    Time.use_zone(time_zone, &block)
  end
end
