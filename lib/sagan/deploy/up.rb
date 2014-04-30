module Sagan
  module Deploy
    class Up
      attr_reader :git, :heroku

      def initialize(git = Git.new, heroku = Heroku.new)
        @git = git
        @heroku = heroku
      end

      def run
        remotes = git.experimental_remotes

        if remotes.any?
          i = 0
          remote = nil

          begin
            remote = remotes[i]
            unlocked = heroku.unlocked?(remote)

            if unlocked
              deploy_to(remote)
            else
              puts "#{remote} is unavailable"
            end
            i = i + 1
          end until i >= remotes.size || unlocked
        else
          no_experimental_remotes
        end
      end

      private :git, :heroku
      private

      def deploy_to(remote)
        puts "Deploying to #{remote}"

        heroku.lock(remote)
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
