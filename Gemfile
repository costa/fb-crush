source 'https://rubygems.org'

ruby '2.1.5'

gem 'rack-canonical-host'
gem 'rails', '~>4.1.6'
gem 'pg'
gem 'delayed_job_active_record'
gem 'sendgrid'
gem 'pusher'
gem 'strip_attributes'
gem 'omniauth', '~>1.2.1'
gem 'omniauth-facebook', '~>1.6.0'
gem 'haml-rails', '~>0.5.3'
gem 'sass-rails', '~>4.0.0'
gem 'bootstrap-sass', '~>3.0.3'
gem 'coffee-rails', '~>4.0.0'
gem 'jquery-rails', '~>3.0.4'
gem 'turbolinks', '~>2.2.0'
gem 'simple_form', '~>3.0.1'
gem 'uglifier'
gem 'jbuilder', '~>1.2'
gem 'backbone-rails'
gem 'haml_coffee_assets'
gem 'i18n-js', '~>3.0.0.rc7'
group :development do
  gem 'better_errors'
  gem 'letter_opener'
  gem 'binding_of_caller'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-pow'
  # gem 'guard-delayed'  # XXX https://github.com/suranyami/guard-delayed/issues/11
  gem 'terminal-notifier-guard'  # XXX doesn't work ;()
  gem 'html2haml'
  gem 'quiet_assets'
  gem 'rails_layout'
end
group :development, :test do
  gem 'spring-commands-rspec'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'rspec-rails'
  gem 'thin'
  gem 'dotenv-rails'
  gem 'pusher-fake'
end
group :production do
  gem 'unicorn'
  gem 'rails_12factor'
  gem 'exception_notification'
end
group :test do
  gem 'capybara'
  gem 'database_cleaner', '1.0.1'
  gem 'email_spec'
  gem 'factory_girl_rails'
  gem 'forgery'
  gem 'fb_graph-mock'
end
gem 'fb_graph', '~>2.7.10'
