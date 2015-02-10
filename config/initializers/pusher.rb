if defined? PusherFake

  PusherFake.configure do |config|
    config.logger  = Rails.logger
    config.verbose = true
    config.socket_options = {host: Rails.application.secrets.domain_name, port: config.send(:available_port)}  # NOTE won't work with DJ pushing
    # XXX near future: config.webhooks = ["http://#{Rails.application.secrets.domain_name}/pusher/webhook"]
  end

  require 'pusher-fake/support/base'  if ENV['FAKE_PUSHER']  # NOTE should be set for a single process only

end
