class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  protect_from_forgery
  before_filter :update_current_user, :if => :current_user

  def update_current_user
    current_user.touch
  end

  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
end
