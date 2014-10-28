if Rails.env.production?
  FbCrush::Application.config.middleware.use(ExceptionNotification::Rack,
    email: {
      email_prefix: "FB-Crush RTE: ",
      sender_address: %{"FB-Crush notifier" <notifier@#{ENV['CANONICAL_HOST']}>},
      exception_recipients: [ENV['RUNTIME_ERROR_EMAIL']]
    }
  )  if ENV['RUNTIME_ERROR_EMAIL'].present? && ENV['CANONICAL_HOST'].present?
end
