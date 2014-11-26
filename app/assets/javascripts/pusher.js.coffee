window.pusher_async = (pusher_or_key, callback)->

  return _(pusher_async).delay 22, key  unless Pusher?

  callback if typeof pusher_or_key is 'string' then new Pusher pusher_or_key else pusher_or_key
