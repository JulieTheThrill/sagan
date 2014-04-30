require 'sagan'

namespace :sagan do
  desc "Deploy HEAD of your current branch to an open experimental server"
  task :up do
    Sagan::Deploy::Up.new.run
  end

  desc "Release the given experimental server for future deployments"
  task :down, :remote do |t, args|
    Sagan::Deploy::Down.new(args[:remote]).run
  end
end
