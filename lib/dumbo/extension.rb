module Dumbo
  class Extension
    attr_reader :name, :version
    def initialize(name = nil, version = nil)
      @name = name || File.read('Makefile')[/EXTENSION *= *([^\s]*)/,1]
      @version = version || File.read("#{self.name}.control")[/default_version *= *'([^']*)'/,1]
    end

    # main releases without migrations
    def releases
      Dir.glob("#{name}--*.sql").reject{|f| f=~/\d--\d/}
    end

    def available_versions
      versions = releases.map{|f| ExtensionVersion.new f[/#{name}--([\d\.]*?)\.sql/,1] }
      versions.sort
    end

    def install
      execute "DROP EXTENSION IF EXISTS #{name}"
      execute "CREATE EXTENSION #{name} VERSION '#{version}'"
      self
    end

    def obj_id
      @obj_id ||= begin
        result = execute <<-sql
          SELECT e.extname, e.oid
          FROM pg_catalog.pg_extension e
          WHERE e.extname ~ '^(#{name})$'
          ORDER BY 1;
        sql
        result.first['oid']
      end
    end

    def objects
      @objects ||= begin
        result = execute <<-SQL
          SELECT classid::pg_catalog.regclass, objid
          FROM pg_catalog.pg_depend
          WHERE refclassid = 'pg_catalog.pg_extension'::pg_catalog.regclass AND refobjid = '#{obj_id}' AND deptype = 'e'
          ORDER BY 1;
        SQL

        result.map{|r| PgObject.new(r['objid']).get(r['classid'])}
      end
    end

    def types
      objects.select{|o| o.kind_of?(Type)}
    end

    def functions
      objects.select{|o| o.kind_of?(Function)}
    end

    def casts
      objects.select{|o| o.kind_of?(Cast)}
    end

    def operators
      objects.select{|o| o.kind_of?(Operator)}
    end

    private

    def execute(sql)
      ActiveRecord::Base.connection.execute sql
    end

  end
end