module Dumbo
  class Operator < PgObject
    attr_accessor :name,
                  :kind,
                  :hashes,
                  :merges,
                  :leftarg,
                  :rightarg,
                  :result_type,
                  :commutator,
                  :negator,
                  :function_name,
                  :join,
                  :restrict

    identfied_by :name, :leftarg, :rightarg

    def load_attributes
      result = DB.exec <<-SQL
        SELECT
         op.oprname AS name,
         op.oprkind AS kind,
         op.oprcanhash AS hashes,
         op.oprcanmerge AS merges,
         lt.typname AS leftarg,
         rt.typname AS rightarg,
         et.typname AS result_type,
         co.oprname AS commutator,
         ne.oprname AS negator,
         op.oprcode AS function_name,
         op.oprjoin AS join,
         op.oprrest AS restrict,
         description
        FROM pg_operator op
        LEFT OUTER JOIN pg_type lt ON lt.oid=op.oprleft
        LEFT OUTER JOIN pg_type rt ON rt.oid=op.oprright
        JOIN pg_type et on et.oid=op.oprresult
        LEFT OUTER JOIN pg_operator co ON co.oid=op.oprcom
        LEFT OUTER JOIN pg_operator ne ON ne.oid=op.oprnegate
        LEFT OUTER JOIN pg_description des ON des.objoid=op.oid
        WHERE op.oid = #{oid}
      SQL

      result.first.each do |k, v|
        send("#{k}=", v) rescue nil
      end

      result.first
    end

    def to_sql
      attrs = [:leftarg, :rightarg, :commutator, :negator, :restrict, :join].reduce([]) do |mem, attr|
        mem << "#{attr.to_s.upcase} = #{public_send(attr)}" if public_send(attr) &&  public_send(attr) !='-'
        mem
      end

      attrs << "HASHES" if hashes == 't'
      attrs << "MERGES" if merges == 't'
      atttr_str = attrs.join(",\n  ")
      <<-SQL.gsub(/^ {6}/, '')
      CREATE OPERATOR #{name} (
        PROCEDURE = #{function_name},
        #{atttr_str}
      );
      SQL
    end

    def drop
      "DROP OPERATOR IF EXISTS #{name} (#{leftarg}, #{rightarg});"
    end
  end
end
