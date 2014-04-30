module Sagan
  module Mocks
    class Git
      def force_push(*); end
      def remotes(*); end
    end
  end
end
