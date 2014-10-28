# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

use Rack::CanonicalHost, ENV['DOMAIN_NAME']  if ENV['DOMAIN_NAME'].present?

run Rails.application
