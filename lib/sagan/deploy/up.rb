module Sagan
  module Deploy
    class Up
      def initialize(git = Git.new, server_type = Heroku)
        @git = git
        @server_type = server_type
      end

      def run
        remotes = git.experimental_remotes

        if remotes.any?
          i = 0

          begin
            server = server_type.new(remotes[i])
            unlocked = server.unlocked?

            if unlocked
              deploy_to(server)
            else
              show_unavailable_message(server)
            end
            i = i + 1
          end until i >= remotes.size || unlocked
        else
          no_experimental_remotes
        end
      end

      private

      attr_reader :git, :server_type

      def deploy_to(server)
        puts "Deploying to #{server.remote}"

        server.lock
        server.maintenance_on
        git.force_push(server.remote)
        server.set_deployed_branch(git.current_branch)

        puts 'Resetting database'
        server.reset_db

        server.maintenance_off

        puts "Successfully deployed to http://www.#{server.remote}.schoolify.me"
      end

      def no_experimental_remotes
        puts "You don't have any experimental git remotes"
        puts "Please add exp[1-n]"
      end

      def show_unavailable_message(server)
        puts "#{server.remote} is unavailable - branch #{server.deployed_branch}"
      end
    end
  end
end
