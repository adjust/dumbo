module Dumbo
  module Command
    class Migrations < Dumbo::Command::Base
      def exec
        old_version, new_version = Extension.versions.last(2).map(&:to_s)

        if new_version
          ExtensionMigrator.new(Extension.name, old_version, new_version).create
        end
      end
    end
  end
end
