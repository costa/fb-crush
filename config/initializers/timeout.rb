# NOTE Heroku has (probably good) strict policies regarding request timing
# the longest-running request should finish after 30 seconds on the client side
# or else a proxy error will be returned.
# However, an even stricter limits are set for a dyno shutdown - 10 seconds.
# NOTE It is a generally good idea to see longer-running request as errors
# so this will actually make them such.
# https://devcenter.heroku.com/articles/dynos#graceful-shutdown-with-sigterm
Rack::Timeout.timeout = 9  if defined? Rack::Timeout  # seconds
