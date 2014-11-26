if defined? PusherFake

  PusherFake.configure do |config|
    config.logger  = Rails.logger
    config.verbose = true
    config.socket_options = {host: ENV['DOMAIN_NAME'], port: config.send(:available_port)}
    config.webhooks = ["http://#{ENV['DOMAIN_NAME']}/pusher/webhook"]
  end

  require 'pusher-fake/support/base'  if ENV['FAKE_PUSHER']  # NOTE should be set for a single process only

end
