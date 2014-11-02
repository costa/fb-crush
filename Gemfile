source 'https://rubygems.org'
ruby '2.1.3'
gem 'rack-canonical-host'
gem 'rails', '~>4.1.6'
gem 'pg'
gem 'delayed_job_active_record'
gem 'sendgrid'
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
gem 'i18n-js', github: 'fnando/i18n-js'  # XXX making sure the master has the same issue
group :development do
  gem 'better_errors'
  gem 'letter_opener'
  gem 'binding_of_caller'
  gem 'terminal-notifier-guard', '~>1.5.3'  # XXX https://github.com/Springest/terminal-notifier-guard/issues/19
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-pow'
  gem 'guard-delayed'
  gem 'html2haml'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
end
group :development, :test do
  gem 'spring-commands-rspec'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'rspec-rails'
  gem 'thin'
  gem 'dotenv-rails'
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
