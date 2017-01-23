module Dumbo
  module Types
    class CompositeType < Dumbo::Type
      attr_accessor :attributes

      def load_attributes
        super
        res = DB.exec <<-SQL
        SELECT
          attname,
          format_type(t.oid,NULL) AS typname
        FROM pg_attribute att
        JOIN pg_type t ON t.oid=atttypid

        WHERE att.attrelid=#{typrelid}
        ORDER by attnum
        SQL

        attribute = Struct.new(:name, :type)
        @attributes = res.map { |r| attribute.new(r['attname'], r['typname']) }
      end

      def to_sql
        attr_str = attributes.map { |a| "#{a.name} #{a.type}" }.join(",\n  ")
        <<-SQL.gsub(/^ {6}/, '')
        CREATE TYPE #{name} AS (
          #{attr_str}
        );
        SQL
      end
    end
  end
end
