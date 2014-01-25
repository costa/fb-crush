if Rails.env.test?

  module I18n

    def self.just_raise_that_exception(*args)
      raise args.first
    end

  end
  I18n.exception_handler = :just_raise_that_exception

  module ActionView::Helpers::TranslationHelper

    def translate_with_raise(key, options = {})
      translate_without_raise key, options.merge(:raise => true)
    end
    alias_method_chain :translate, :raise
    alias_method :t, :translate

  end

end
