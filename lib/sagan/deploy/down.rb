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
          usage
        else
          if has_experimental_remote?(remote)
            puts "Unlocking #{remote}"

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
