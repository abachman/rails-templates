# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotification::Notifiable
  include AuthlogicMethods

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user
  before_filter :require_user

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout 'default'
end
