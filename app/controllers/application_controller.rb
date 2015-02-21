class ApplicationController < ActionController::Base
  include Concerns::Authentication
  include Concerns::Facebook

  protect_from_forgery

  def default_url_options
    super.merge :protocol => ENV['SSL_ENABLED'].present?? :https: :http
  end

end
