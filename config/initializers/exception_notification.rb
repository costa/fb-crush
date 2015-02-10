if defined?(ExceptionNotification) && ENV['RUNTIME_ERROR_EMAIL'].present?
  FbCrush::Application.config.middleware.use(ExceptionNotification::Rack,
    email: {
      email_prefix: "FB-crush RTE: ",
      sender_address: %{"FB-crush notifier" <notifier@#{ENV['DOMAIN_NAME']}>},
      exception_recipients: [ENV['RUNTIME_ERROR_EMAIL']]
    }
  )
end
