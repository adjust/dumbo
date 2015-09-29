module Dumbo
  class EnumType < Type
    attr_accessor :labels
    identfied_by :name

    def load_attributes
      super

      res = execute <<-SQL
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
