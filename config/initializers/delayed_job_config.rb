# Defaults commented out
# Delayed::Worker.destroy_failed_jobs = true
# Delayed::Worker.sleep_delay = 5.seconds
# Delayed::Worker.max_attempts = 25
# Delayed::Worker.max_run_time = 4.hours
# Delayed::Worker.read_ahead = 5
# Delayed::Worker.default_queue_name =
Delayed::Worker.delay_jobs = !Rails.env.test?  # XXX near future? Rails.env.production?  # true
# Delayed::Worker.raise_signal_exceptions = false  # :term
# Delayed::Worker.logger = # Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))  if Rails.env.production?
