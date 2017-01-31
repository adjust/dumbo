module Dumbo
  module Command
    class Migrations < Dumbo::Command::Base
      def exec
        if versions.size < 2
          yield 'error', 'The extension doesn\'t have enough versions to migrate.' if block_given?
          return
        end

        old_version, new_version = versions.last(2).map(&:to_s)

        migrator = ExtensionMigrator.new(Extension.name, old_version, new_version)
        migrator.create

        if block_given?
          yield 'created', migrator.upgrade_migration_filename
          yield 'created', migrator.downgrade_migration_filename
        end
      end

      private

      def versions
        @versions ||= Extension.versions
      end
    end
  end
end
