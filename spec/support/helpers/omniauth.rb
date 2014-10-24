module Omniauth

  module Mock
    def auth_mock
      OmniAuth.config.mock_auth[:facebook] = {
        provider: 'facebook',
        uid: '123545',
        info: {
          name: 'mockuser'
        },
        credentials: {
          token: 'mock_token',
          secret: 'mock_secret'
        }
      }
    end
  end

end
