if defined?(Byebug) && ENV['RUBY_DEBUG_PORT'].present?
  Byebug.start_server 'localhost', ENV['RUBY_DEBUG_PORT'].to_i
end
