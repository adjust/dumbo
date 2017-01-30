module Dumbo
  module Command
    class Bump < Dumbo::Command::Base
      attr_accessor :level

      def initialize(level)
        @level = level
      end

      def exec
        Extension.version!(ExtensionVersion.new_from_string(Extension.version).bump(level).to_s)
      end
    end
  end
end
