module Sagan
  module Deploy
    class Up
      AVAILABILITY_KEY = 'EXPERIMENTAL_AVAILABLE'

      attr_reader :git, :heroku

      def initialize(git = Git.new, heroku = Heroku.new)
        @git = git
        @heroku = heroku
      end

      def run
        if experimental_remotes.any?
          i = 0
          remote = nil

          begin
            remote = experimental_remotes[i]
            available = experimental_available?(remote)

            if available
              deploy_to(remote)
            else
              puts "#{remote} is unavailable"
            end
            i = i + 1
          end until i >= experimental_remotes.size || available
        else
          no_experimental_remotes
        end
      end

      private_constant :AVAILABILITY_KEY
      private :git, :heroku
      private

      def experimental_available?(remote)
        heroku.get_config(AVAILABILITY_KEY, remote) == "true\n"
      end

      def experimental_remotes
        unless @experimental_remotes
          remotes = git.remotes.split("\n")

          @experimental_remotes = remotes.select { |r| r =~ /^exp\d+$/ }
        end

        @experimental_remotes
      end

      def deploy_to(remote)
        puts "deploying to #{remote}"

        heroku.set_config(AVAILABILITY_KEY, false, remote)
        heroku.maintenance_on(remote)
        git.force_push(remote)

        puts 'Resetting database'
        heroku.reset_db(remote)

        heroku.maintenance_off(remote)

        puts "Successfully deployed to http://www.#{remote}.schoolify.me"
      end

      def no_experimental_remotes
        puts "You don't have any experimental git remotes"
        puts "Please add exp[1-n]"
      end
    end
  end
end
