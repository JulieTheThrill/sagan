module Sagan
  module Deploy
    class Down
      def initialize(remote, git = Git.new, server_type = Heroku)
        @git = git
        @remote = remote
        @server = server_type.new(remote)

        usage if remote.nil?
      end

      def run
        if has_experimental_remote?(remote)
          puts "Unlocking #{remote}"

          server.unlock
          server.maintenance_on

          puts "#{remote} is now available for use"
        else
          puts "Experimental remote #{remote} doesn't exist"
        end
      end

      private

      attr_reader :git, :remote, :server

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
