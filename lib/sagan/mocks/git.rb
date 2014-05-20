module Sagan
  module Mocks
    class Git
      def current_branch; end
      def experimental_remotes(*); end
      def force_push(*); end
    end
  end
end
