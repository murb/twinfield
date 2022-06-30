module Twinfield
  module Create
    class Error < StandardError
      attr_accessor :object

      def initialize message, object:
        super(message)
        self.object = object
      end
    end

    class Finalized < Error
      attr_accessor :object

      def initialize message, object:
        super(message, object: object)
        self.object = object
      end
    end

    class EmptyInvoice < Error
      attr_accessor :object

      def initialize message, object:
        super(message, object: object)
        self.object = object
      end
    end
  end
end