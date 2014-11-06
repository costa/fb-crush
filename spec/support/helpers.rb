RSpec.configure do |config|
  config.include Omniauth::Mock
  config.include FbGraph::Mock
end
OmniAuth.config.test_mode = true
