module Dumbo
  class ExtensionMigrator
    attr_reader :old_version, :new_version, :name

    PG_OBJECTS = [:types, :functions, :casts, :operators, :aggregates]

    def initialize(name, old_version, new_version)
      @name = name
      @old_version = Extension.new(name, old_version).create
      @old_version.objects
      @new_version = Extension.new(name, new_version).create
      @new_version.objects
    end

    def upgrade_migration_filename
      "#{name}--#{old_version.version}--#{new_version.version}.sql"
    end

    def downgrade_migration_filename
      "#{name}--#{new_version.version}--#{old_version.version}.sql"
    end

    def create
      File.open(upgrade_migration_filename, 'w') { |f| f.puts upgrade }

      File.open(downgrade_migration_filename, 'w') { |f| f.puts downgrade }
    end

    def upgrade
      PG_OBJECTS.map do |type|
        diff = object_diff(type, :upgrade)
        "----#{type}----\n" + diff unless diff.empty?
      end.compact.join("\n")
    end

    def downgrade
      PG_OBJECTS.reverse.map do |type|
        diff = object_diff(type, :downgrade)
        "----#{type}----\n" + diff unless diff.empty?
      end.compact.join("\n")
    end

    def function_diff
      object_diff(@old_version.functions, @new_version.functions)
    end

    def cast_diff
      object_diff(@old_version.casts, @new_version.casts)
    end

    def object_diff(type, direction)
      ids = @old_version.public_send(type).map(&:identify) | @new_version.public_send(type).map(&:identify)
      sqls = ids.map do |id|
        new_version_obj = @new_version.public_send(type).find { |n| n.identify == id }
        old_version_obj = @old_version.public_send(type).find { |n| n.identify == id }
        case direction
        when :upgrade
          migrate(old_version_obj, new_version_obj)
        when :downgrade
          migrate(new_version_obj, old_version_obj)
        end
      end

      sqls.compact.join("\n----\n")
    end

    def migrate(from, to)
      if from && to
        from.migrate_to(to)
      elsif from
        from.drop
      elsif to
        to.to_sql
      end
    end
  end
end
