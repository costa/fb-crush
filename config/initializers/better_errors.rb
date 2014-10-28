if Rails.env.development?
  BetterErrors::Middleware.allow_ip! ENV['MY_PRIVATE_IP']  if ENV['MY_PRIVATE_IP'].present?
end
