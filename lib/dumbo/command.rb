module Dumbo
  module Command
    class Base
      def self.exec(*params, &block)
        new(*params).exec(&block)
      end
    end
  end
end
