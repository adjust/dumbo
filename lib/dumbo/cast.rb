module Dumbo
  class Cast < PgObject
    attr_accessor :source_type, :target_type, :function_name, :argument_type, :context
    identfied_by :source_type, :target_type

    def load_attributes
      result = execute <<-SQL
      SELECT
        format_type(st.oid,NULL) AS source_type,
        format_type(st.oid,NULL) AS argument_type,
        format_type(tt.oid,tt.typtypmod) AS target_type,
        proname AS function_name,
      CASE WHEN ca.castcontext = 'e' THEN NULL
            WHEN ca.castcontext = 'a' THEN 'ASSIGNMENT'
            ELSE 'IMPLICIT'
       END AS context

       FROM pg_cast ca
       JOIN pg_type st ON st.oid=castsource
       JOIN pg_type tt ON tt.oid=casttarget
       LEFT JOIN pg_proc pr ON pr.oid=castfunc
       LEFT OUTER JOIN pg_description des ON (des.objoid=ca.oid AND des.objsubid=0 AND des.classoid='pg_cast'::regclass)
      WHERE ca.oid = #{oid}
      SQL

      result.first.each do |k, v|
        send("#{k}=", v) rescue nil
      end

      result.first
    end

    def drop
      "DROP CAST (#{source_type} AS #{target_type});"
    end

    def to_sql
      attributes = []
      attributes << "WITH FUNCTION #{function_name}(#{source_type})" if function_name
      attributes << 'WITHOUT FUNCTION' unless function_name
      attributes << context if context

      <<-SQL.gsub(/^ {6}/, '')
      CREATE CAST (#{source_type} AS #{target_type})
      #{attributes.join("\nAS ")};
      SQL
    end
  end
end
