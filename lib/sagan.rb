require File.join(File.dirname(__FILE__), 'railtie.rb') if defined?(Rails) && Rails::VERSION::MAJOR >= 3

require "sagan/version"
require "sagan/deploy"
require "sagan/git"
require "sagan/heroku"

module Sagan
end
