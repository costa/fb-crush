if defined?(ExceptionNotification) && Rails.application.secrets.exception_notification_email.present?
  FbCrush::Application.config.middleware.use(ExceptionNotification::Rack,
    email: {
      email_prefix: "fb-CRUSH RTE: ",
      sender_address: %{"fb-CRUSH notifier" <notifier@#{Rails.application.secrets.domain_name}>},
      exception_recipients: [Rails.application.secrets.exception_notification_email]
    }
  )
end
