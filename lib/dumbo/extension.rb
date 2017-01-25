module Dumbo
  class Extension < Struct.new(:name, :version)
    class << self
      def name
        @_name ||= File.read(makefile)[/EXTENSION\s*=\s*([^\s]*)/, 1]
      rescue SystemCallError => e
        STDERR.puts("File not found: #{makefile}")
        raise e
      end

      def version
        @_version ||= File.read(control_file)[/default_version\s*=\s*'([^']*)'/, 1]
      rescue SystemCallError => e
        STDERR.puts("File not found: #{control_file}")
        raise e
      end

      def versions
        new.versions
      end

      def version!(new_version)
        content = File.read(control_file)
        new_content = content.gsub(version, new_version)
        File.open(control_file, 'w') { |file| file.puts new_content }
      end

      def file_name
        "#{name}--#{version}.sql"
      end

      private

      def makefile
        'Makefile'
      end

      def control_file
        "#{name}.control"
      end
    end

    def name
      self[:name] ||= Extension.name
    end

    def version
      self[:version] ||= Extension.version
    end

    # main releases without migrations
    def releases
      Dir.glob("#{name}--*.sql").reject { |f| f =~ /\d--\d/ }
    end

    def versions
      releases.map do |file_name|
        if version_string = file_name[/([\d+\.]+)\.sql$/, 1]
          ExtensionVersion.new_from_string(version_string)
        else
          nil
        end
      end.compact.sort
    end

    def create
      DB.exec "DROP EXTENSION IF EXISTS #{name}"

      create_sql = "CREATE EXTENSION #{name}"
      create_sql = "#{create_sql} VERSION '#{version}'" unless version.nil?

      DB.exec create_sql
      self
    end

    def obj_id
      @obj_id ||= begin
        result = DB.exec <<-SQL
          SELECT e.extname, e.oid
          FROM pg_catalog.pg_extension e
          WHERE e.extname ~ '^(#{name})$'
          ORDER BY 1;
        SQL
        result.first['oid']
      end
    end

    def objects
      @objects ||= begin
        result = DB.exec <<-SQL
          SELECT classid::pg_catalog.regclass, objid
          FROM pg_catalog.pg_depend
          WHERE refclassid = 'pg_catalog.pg_extension'::pg_catalog.regclass AND refobjid = '#{obj_id}' AND deptype = 'e'
          ORDER BY 1;
        SQL

        result.map { |r| PgObject.new(r['objid']).get(r['classid']) }
      end
    end

    def types
      objects.select { |o| o.kind_of?(Type) }
    end

    def functions
      objects.select { |o| o.kind_of?(Function) }
    end

    def casts
      objects.select { |o| o.kind_of?(Cast) }
    end

    def operators
      objects.select { |o| o.kind_of?(Operator) }
    end

    def aggregates
      objects.select { |o| o.kind_of?(Aggregate) }
    end
  end
end
