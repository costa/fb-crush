guard 'bundler' do
  watch('Gemfile')
  watch(%r{^\.rvm})
  # Uncomment next line if Gemfile contain `gemspec' command
  # watch(/^.+\.gemspec/)
end

guard 'spork', :test_unit => false, :rspec_env => { 'RAILS_ENV' => 'test' } do  # , :cucumber_env => { 'RAILS_ENV' => 'test' }
  watch(%r{^config/})
  watch(%r{^lib/.*\.rb$})
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
end

guard 'rspec', {
  cmd: 'rspec --drb -fd',
  run_all: {cmd: 'rspec --drb -b -p -fd -t ~js'},
  all_after_pass: false,
  all_on_start: false
} do
  watch('spec/spec_helper.rb')                        { "spec" }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('spec/factories.rb')                          { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^app/views/(.+)/.*\.(erb|haml|rjs)$})      { |m| "spec/features/#{m[1]}_spec.rb" }
end
