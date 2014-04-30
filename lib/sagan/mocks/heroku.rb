module Sagan
  module Mocks
    class Heroku
      def reset_db(*); end
      def get_config(*); end
      def set_config(*); end
      def maintenance_on(*); end
      def maintenance_off(*); end
    end
  end
end
