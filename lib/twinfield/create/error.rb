module Twinfield
  module Create
    class Error < StandardError
      attr_accessor :object

      def initialize message, object: nil
        super(message)
        self.object = object
      end
    end

    class Finalized < Error
    end

    class EmptyInvoice < Error
    end
  end
end
