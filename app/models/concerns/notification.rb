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

      def init_channel(channel)
        for_index.find_each do |obj|
          notify_async_without_delay channel, 'created', obj.to_json
        end
      end

    end

  end

  private

  def notify(event)
    self.class.notify_async pusher_channel, event, as_json  if pusher_channel
  end

end
