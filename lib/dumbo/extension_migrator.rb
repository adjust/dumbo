module Dumbo
  class ExtensionMigrator
    attr_reader :old_version, :new_version, :name
    TYPES = [:types, :functions, :casts, :operators, :aggregates]

    def initialize(name, old_version, new_version)
      @name = name
      @old_version = Extension.new(name, old_version).create
      @old_version.objects
      @new_version = Extension.new(name, new_version).create
      @new_version.objects
    end

    def create
      File.open("#{name}--#{old_version.version}--#{new_version.version}.sql", 'w') do |f|
        f.puts upgrade
      end
      File.open("#{name}--#{new_version.version}--#{old_version.version}.sql", 'w') do |f|
        f.puts downgrade
      end
    end

    def upgrade
      TYPES.map do |type|
        diff = object_diff(type, :upgrade)
        "----#{type}----\n" + diff if diff.present?
      end.compact.join("\n")
    end

    def downgrade
      TYPES.map do |type|
        diff = object_diff(type, :downgrade)
        "----#{type}----\n" + diff if diff.present?
      end.compact.join("\n")
    end

    def function_diff
      object_diff(@old_version.functions, @new_version.functions)
    end

    def cast_diff
      object_diff(@old_version.casts, @new_version.casts)
    end

    def object_diff(type, dir)
      ids = @old_version.public_send(type).map(&:identify) | @new_version.public_send(type).map(&:identify)
      sqls = ids.map do |id|
        new_version_obj = @new_version.public_send(type).find { |n| n.identify == id }
        old_version_obj = @old_version.public_send(type).find { |n| n.identify == id }
        case dir
        when :upgrade
          migrate(old_version_obj, new_version_obj)
        when :downgrade
          migrate(new_version_obj, old_version_obj)
        end
      end

      sqls.join("\n----\n")
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

    private
    def execute(sql)
      ActiveRecord::Base.connection.execute sql
    end
  end
end
