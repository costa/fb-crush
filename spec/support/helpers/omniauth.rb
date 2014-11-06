module Omniauth

  module Mock

    def auth_mock(user = FactoryGirl.build(:user))
      OmniAuth.config.mock_auth[user.provider.to_sym] = {
        provider: user.provider,
        uid: user.uid,
        info: {
          name: user.name
        },
        credentials: {
          token: 'mock_token',
          secret: 'mock_secret'
        }
      }
    end

  end

end
