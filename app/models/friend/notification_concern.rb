module Friend::NotificationConcern
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

  def notify(event)
    self.class.notify_async ego.pusher_channel, event, as_json  if ego.pusher_channel
  end

end
