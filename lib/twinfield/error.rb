module Twinfield
  class Error < StandardError
    attr_accessor :object

    def initialize message, object: nil
      super(message)
      self.object = object
    end
  end
end
