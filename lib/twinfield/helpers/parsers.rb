module Twinfield
  module Helpers
    module Parsers
      def parse_date string
        if string && string != ""
          Date.strptime(string, '%Y%m%d')
        end
      end

      def parse_datetime string
        if string && string != ""
          DateTime.strptime(string, '%Y%m%d%H%M%S')
        end
      end

      def parse_float string
        if string && string != ""
          Float(string)
        end
      end
    end
  end
end
