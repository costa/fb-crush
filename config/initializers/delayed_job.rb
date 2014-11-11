# FROM https://github.com/smartinez87/exception_notification/issues/195
Delayed::Worker.class_eval do

    def handle_failed_job_with_notification(job, error)
      handle_failed_job_without_notification job, error
      ExceptionNotifier.notify_exception error
    end
    alias_method_chain :handle_failed_job, :notification

end

# XXX What I would really like to see is :priority => :realtime_notifications with handle_asynchronously. Alas.
EXTERNAL_BATCH_PRIORITY = 64
