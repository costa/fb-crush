source 'https://rubygems.org'
ruby '2.0.0'
gem 'pg'
gem 'sendgrid'
gem 'rails', :github => 'rails/rails', :branch => '4-0-stable'  # XXX until the translation_helper patch makes it through
gem 'constfig', '~>0.0.4'
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
gem 'draper', '~>1.3.0'
gem 'uglifier'
gem 'figaro'
gem 'jbuilder', '~>1.2'
group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :rbx]
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'spork-rails', github: 'sporkrb/spork-rails'
  gem 'guard-spork', github: 'guard/guard-spork'
  gem 'guard-pow'
  gem 'html2haml'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
end
group :development, :test do
  gem 'pry-rails'
  gem 'pry-debugger'
  gem 'pry-stack_explorer'
  gem 'rspec-rails'
  gem 'thin'
end
group :production do
  gem 'unicorn'
  gem 'rails_12factor'
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
