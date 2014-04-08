module Dumbo
  class RangeType < Type
    attr_accessor :subtype, :subtype_opclass, :collation,
                  :canonical,:subtype_diff

    def load_attributes
      super
      result = execute <<-SQL
        SELECT
          st.typname AS subtype,
          opc.opcname AS subtype_opclass,
          col.collname AS collation,
          rngcanonical AS canonical,
          rngsubdiff AS  subtype_diff
        FROM pg_range
        LEFT JOIN pg_type st ON st.oid=rngsubtype
        LEFT JOIN pg_collation col ON col.oid=rngcollation
        LEFT JOIN pg_opclass opc ON opc.oid=rngsubopc
        WHERE rngtypid=#{oid}
        SQL

      result.first.each do |k,v|
        send("#{k}=",v) rescue nil
      end
      result.first
    end




    def to_sql
      attr_str = [:subtype, :subtype_opclass, :collation, :canonical,:subtype_diff].map do |a|
        [a, public_send(a)]
      end.select{|k,v| v && v != '-' }.map{|k,v| "#{k.upcase}=#{v}"}.join(",\n  ")

      <<-SQL.gsub(/^ {6}/, '')
      CREATE TYPE #{name} AS RANGE (
        #{attr_str}
      );
      SQL
    end
  end
end