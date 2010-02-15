# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '284e1b115bbe77af18c3a1fc60b724ba'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :key
  
  before_filter :load_user, :init_stylesheets, :init_warnings

  protected

  def init_stylesheets
    @stylesheets ||= []
    @stylesheets << controller_name if css_exists?(controller_name)
  end

  def css_exists?(filename)
    File.exists?(File.join(RAILS_ROOT, "public", "stylesheets", "#{filename}.css"))
  end

  def init_warnings
    @uncategorized = @user.entries.uncategorized.size if @user

    @warnings = [@uncategorized].any?
  end

  # TODO: unstub this.
  def load_user
    @user = User.find_by_username("andy")
  end
end
