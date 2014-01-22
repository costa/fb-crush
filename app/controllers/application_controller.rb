class ApplicationController < ActionController::Base
  include Concerns::Authentication
  include Concerns::Facebook
  protect_from_forgery

end
