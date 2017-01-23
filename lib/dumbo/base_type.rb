module Dumbo
  class BaseType < Type
    attr_accessor :input_function,
                  :output_function,
                  :receive_function,
                  :send_function,
                  :analyze_function,
                  :category,
                  :default,
                  :alignment,
                  :storage,
                  :type,
                  :internallength,
                  :attribute_name,
                  :typrelid

    def load_attributes
      sql = <<-SQL
        SELECT
        t.typname AS name,
        t.typinput AS input_function,
        t.typoutput AS output_function,
        t.typreceive AS receive_function,
        t.typsend AS send_function,
        t.typanalyze AS analyze_function,
        t.typcategory AS category,
        t.typdefault AS default,
        t.typrelid,
        CASE WHEN t.typalign = 'i' THEN 'int' WHEN t.typalign = 'c' THEN 'char' WHEN t.typalign = 's' THEN 'short'  WHEN t.typalign = 'd' THEN 'double' ELSE NULL END AS alignment,
        CASE WHEN t.typstorage = 'p' THEN 'PLAIN' WHEN t.typstorage = 'e' THEN 'EXTENDED' WHEN t.typstorage = 'm' THEN 'MAIN'  WHEN t.typstorage = 'x' THEN 'EXTENDED' ELSE NULL END AS storage,
        t.typtype AS type,
        t.typlen AS internallength,
        format_type(t.oid, null) AS alias, e.typname as element,
        description, ct.oid AS taboid,
        (SELECT array_agg(label) FROM pg_seclabels sl1 WHERE sl1.objoid=t.oid) AS labels,
        (SELECT array_agg(provider) FROM pg_seclabels sl2 WHERE sl2.objoid=t.oid) AS providers
         FROM pg_type t
         LEFT OUTER JOIN pg_type e ON e.oid=t.typelem
         LEFT OUTER JOIN pg_class ct ON ct.oid = t.typrelid AND ct.relkind <> 'c'
         LEFT OUTER JOIN pg_description des ON (des.objoid=t.oid AND des.classoid='pg_type'::regclass)
        WHERE t.typtype != 'd' AND t.typnamespace = 2200::oid
          AND ct.oid IS NULL
          AND t.oid = #{oid}
      SQL

      result = DB.exec(sql)
      result.first.each do |k, v|
        send("#{k}=", v) rescue nil
      end

      result.first
    end

    def to_sql
      <<-SQL.gsub(/^ {8}/, '')
        CREATE TYPE #{name}(
          INPUT=#{input_function},
          OUTPUT=#{output_function},
          RECEIVE=#{receive_function},
          SEND=#{send_function},
          ANALYZE=#{analyze_function},
          CATEGORY='#{category}',
          DEFAULT='#{default}',
          INTERNALLENGTH=#{internallength},
          ALIGNMENT=#{alignment},
          STORAGE=#{storage}
        );
        SQL
    end
  end
end
