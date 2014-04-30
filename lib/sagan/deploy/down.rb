module Sagan
  module Deploy
    class Down
      AVAILABILITY_KEY = 'EXPERIMENTAL_AVAILABLE'

      attr_reader :git, :heroku

      def initialize(git = Git.new, heroku = Heroku.new)
        @git = git
        @heroku = heroku
      end


      def down(remote)
        if remote.nil?
          puts 'You must provide a remote to tear down'
          puts 'rake exp:down[myremote]'
        else
          if has_experimental_remote?(remote)
            puts "Starting to make #{remote} available"

            heroku.set_config(AVAILABILITY_KEY, true, remote)
            heroku.maintenance_on(remote)

            puts "#{remote} is now available for use"
          else
            puts "Experimental remote #{remote} doesn't exist"
          end
        end
      end

      private_constant :AVAILABILITY_KEY
      private :git, :heroku
      private

      def experimental_remotes
        unless @experimental_remotes
          remotes = git.remotes.split("\n")

          @experimental_remotes = remotes.select { |r| r =~ /^exp\d+$/ }
        end

        @experimental_remotes
      end

      def has_experimental_remote?(remote)
        !!experimental_remotes.detect { |r| r == remote }
      end
    end
  end
end
