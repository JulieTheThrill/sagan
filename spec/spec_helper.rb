require 'bundler'
Bundler.setup

SPEC_ROOT = File.dirname(__FILE__)

Dir[File.join(SPEC_ROOT, "support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
end

require File.join(SPEC_ROOT, '/../lib/sagan')
