require File.join(File.dirname(__FILE__), 'railtie.rb') if defined?(Rails) && Rails::VERSION::MAJOR >= 3

require "sagan/version"
require "sagan/git"
require "sagan/heroku"
require "sagan/deploy/up"
require "sagan/deploy/down"

module Sagan
end
