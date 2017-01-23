module Dumbo
  module Types
    class EnumType < Dumbo::Type
      attr_accessor :labels

      def load_attributes
        super

        res = DB.exec <<-SQL
            SELECT enumlabel
            FROM pg_enum
            WHERE enumtypid = #{oid}
            ORDER by enumsortorder
          SQL
        @labels = res.to_a.map { |r| r['enumlabel'] }
      end

      def to_sql
        lbl_str = labels.map { |l| "'" + l + "'" }.join(",\n  ")

        <<-SQL.gsub(/^ {6}/, '')
        CREATE TYPE #{name} AS ENUM (
          #{lbl_str}
        );
        SQL
      end
    end
  end
end
