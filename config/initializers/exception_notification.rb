if defined?(ExceptionNotification) && Rails.application.secrets.exception_notification_email.present?
  FbCrush::Application.config.middleware.use(ExceptionNotification::Rack,
    email: {
      email_prefix: "FB-crush RTE: ",
      sender_address: %{"FB-crush notifier" <notifier@#{Rails.application.secrets.domain_name}>},
      exception_recipients: [Rails.application.secrets.exception_notification_email]
    }
  )
end
