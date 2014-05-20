module Sagan
  module Mocks
    class Heroku
      attr_reader :remote

      def initialize(remote)
        @remote = remote
      end
      def deployed_branch; end
      def set_deployed_branch(branch); end
      def lock; end
      def unlock; end
      def unlocked?; end
      def maintenance_on; end
      def maintenance_off; end
      def reset_db; end
    end
  end
end
