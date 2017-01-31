module Dumbo
  class Extension < Struct.new(:name, :version)
    class << self
      def name
        return unless File.exists?(makefile)

        File.read(makefile)[/EXTENSION\s*=\s*([^\s]*)/, 1]
      end

      def version
        return unless File.exists?(control_file)

        File.read(control_file)[/default_version\s*=\s*'([^']*)'/, 1]
      end

      def versions
        new.versions
      end

      def version!(new_version)
        content = File.read(control_file)
        new_content = content.gsub(/\n\s*default_version\s*=.*[\n\Z]/, "\ndefault_version = '#{new_version}'\n")
        File.open(control_file, 'w') { |file| file.puts new_content }
      end

      def file_name
        Dumbo.extension_file("#{name}--#{version}.sql")
      end

      def makefile
        Dumbo.extension_file('Makefile')
      end

      def control_file
        Dumbo.extension_file("#{name}.control")
      end

      def config_file
        Dumbo.extension_file('config', 'database.yml')
      end

      def make_install
        return unless File.exists?(makefile)

        Kernel.system('make install > /dev/null')
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
      Dumbo.extension_files("#{name}--*.sql").reject { |file| file =~ /\d--\d/ }
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

      Extension.make_install

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

        result.map { |r| PgObject::Base.new(r['objid']).get(r['classid']) }
      end
    end

    def types
      objects.select { |o| o.kind_of?(PgObject::Type::Base) }
    end

    def functions
      objects.select { |o| o.kind_of?(PgObject::Function) }
    end

    def casts
      objects.select { |o| o.kind_of?(PgObject::Cast) }
    end

    def operators
      objects.select { |o| o.kind_of?(PgObject::Operator) }
    end

    def aggregates
      objects.select { |o| o.kind_of?(PgObject::Aggregate) }
    end
  end
end
