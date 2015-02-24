module Notification
  extend ActiveSupport::Concern

  included do

    after_create { notify 'created' }
    after_update { notify 'updated' }
    after_destroy { notify 'destroyed' }

    class << self

      def notify_async(channel, event, json)
        Pusher[channel].trigger event, json
      end
      handle_asynchronously :notify_async, :priority => REALTIME_NOTIFICATIONS_PRIORITY

    end

  end

  private

  def notify?
    true
  end

  # XXX must batch/throttle
  def notify(event)
    self.class.notify_async pusher_channel, event, as_json  if notify? && pusher_channel
  end

end
