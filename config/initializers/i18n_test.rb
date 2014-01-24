if Rails.env.test?
  # NOTE from http://guides.rubyonrails.org/i18n.html#using-different-exception-handlers
  module I18n
    class JustRaiseExceptionHandler < ExceptionHandler

      def call(exception, locale, key, options)
        raise exception.to_exception
      end

    end
  end

  I18n.exception_handler = I18n::JustRaiseExceptionHandler.new
end
