class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_filter :set_tenant

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  protect_from_forgery
  before_filter :update_current_user, :if => :current_user
  before_filter :set_locale

  def set_tenant
    if request.subdomain.blank? && request.host != 'localhost'
      redirect_to request.url.sub(request.domain, "www.#{request.domain}")
    end
    @domain = Domain.find_or_create_by_name(request.host)
    set_current_tenant(@domain)
  end

  def set_locale
    I18n.locale = http_accept_language.preferred_language_from(%w[en fr es])
  end

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
