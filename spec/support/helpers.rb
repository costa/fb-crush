RSpec.configure do |config|
  config.include Omniauth::Mock
end
OmniAuth.config.test_mode = true
