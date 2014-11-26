class PusherController < ApplicationController

  def webhook
    webhook = Pusher::WebHook.new(request)
    if webhook.valid?
      webhook.events.each do |event|
        case event['name']
        when 'channel_occupied'
          User.init_channel_async event['channel']
          # TODO start real-time suggestions
        when 'channel_vacated'
          # TODO stop real-time suggestions
        end
      end
      render text: 'ok'
    else
      render text: 'invalid', status: 401
    end
  end

end
