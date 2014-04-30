module Sagan
  module Mocks
    class Git
      def force_push(*); end
      def experimental_remotes(*); end
    end
  end
end
