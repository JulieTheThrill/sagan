require 'sagan'

namespace :sagan do
  desc "Deploy HEAD of your current branch to an open experimental server"
  task :up do
    Sagan::Deploy.new.up
  end

  desc "Release the given experimental server for future deployments"
  task :down, :remote do |t, args|
    Sagan::Deploy.new.down(args[:remote])
  end
end
