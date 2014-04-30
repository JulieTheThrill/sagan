module Sagan
  module Deploy
    class Down
      attr_reader :git, :heroku, :remote

      def initialize(remote, git = Git.new, heroku = Heroku.new)
        @git = git
        @heroku = heroku
        @remote = remote

        usage if remote.nil?
      end

      def run
        if has_experimental_remote?(remote)
          puts "Unlocking #{remote}"

          heroku.unlock(remote)
          heroku.maintenance_on(remote)

          puts "#{remote} is now available for use"
        else
          puts "Experimental remote #{remote} doesn't exist"
        end
      end

      private :git, :heroku, :remote
      private

      def has_experimental_remote?(remote)
        !!git.experimental_remotes.detect { |r| r == remote }
      end

      def usage
        puts 'You must provide an experimental remote'
        puts 'rake exp:down[myremote]'
      end
    end
  end
end
