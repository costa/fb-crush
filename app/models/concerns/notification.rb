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

      def notifications_disabled?
        !!@_notifications_disabled
      end

      def disable_notifications(disable=true)  # NOTE NOT thread safe
        were = @_notifications_disabled
        @_notifications_disabled = disable
        yield  if block_given?
        @_notifications_disabled = were
      end

    end

  end

  private

  def notify?
    !self.class.notifications_disabled?
  end

  # XXX must batch/throttle
  def notify(event)
    self.class.notify_async pusher_channel, event, as_json  if notify? && pusher_channel
  end

end
