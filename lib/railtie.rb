require 'rails'

module Sagan
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'sagan/tasks.rb'
    end
  end
end
