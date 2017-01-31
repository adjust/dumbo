module Dumbo
  module PgObject
    class Aggregate < Dumbo::PgObject::Base
      attr_accessor :name, :sfunc, :transname, :ffunc, :input_data_type, :state_data_type,
                    :initial_condition, :sort_operator
      identfied_by :name, :input_data_type

      def load_attributes
        result = DB.exec <<-SQL
          SELECT
          proname AS name,
          pg_get_function_arguments(pr.oid) AS input_data_type,
          aggtransfn AS sfunc,
          aggfinalfn AS ffunc,
          agginitval AS initial_condition,
          op.oprname AS sort_operator,
          proargtypes,
          aggtranstype AS state_data_type , proacl,
          CASE WHEN (tt.typlen = -1 AND tt.typelem != 0) THEN (SELECT at.typname FROM pg_type at WHERE at.oid = tt.typelem) || '[]' ELSE tt.typname END as state_data_type,
          prorettype AS aggfinaltype,
          --CASE WHEN (tf.typlen = -1 AND tf.typelem != 0) THEN (SELECT at.typname FROM pg_type at WHERE at.oid = tf.typelem) || '[]' ELSE tf.typname END as ffunc,
          description,
          (SELECT array_agg(label) FROM pg_seclabels sl1 WHERE sl1.objoid=aggfnoid) AS labels,
          (SELECT array_agg(provider) FROM pg_seclabels sl2 WHERE sl2.objoid=aggfnoid) AS providers, oprname, opn.nspname as oprnsp
          FROM pg_aggregate ag
          LEFT OUTER JOIN pg_operator op ON op.oid=aggsortop
          LEFT OUTER JOIN pg_namespace opn ON opn.oid=op.oprnamespace
          JOIN pg_proc pr ON pr.oid = ag.aggfnoid
          JOIN pg_type tt on tt.oid=aggtranstype
          JOIN pg_type tf on tf.oid=prorettype
          LEFT OUTER JOIN pg_description des ON (des.objoid=aggfnoid::oid AND des.classoid='pg_aggregate'::regclass)
          WHERE aggfnoid = #{oid}
        SQL

        result.first.each do |k, v|
          send("#{k}=", v) rescue nil
        end

        result.first
      end

      def to_sql
        attributes = []
        attributes << "SFUNC = #{sfunc}"
        attributes << "STYPE = #{state_data_type}"
        attributes << "FINALFUNC = #{ffunc}" if ffunc && ffunc != '-'
        attributes << "INITCOND = '#{initial_condition}'" if initial_condition
        attributes << "SORTOP = \"#{sort_operator}\"" if sort_operator

        <<-SQL.gsub(/^ {6}/, '')
        CREATE AGGREGATE #{name}(#{input_data_type}) (
          #{attributes.join(",\n  ")}
        );
        SQL
      end

      def drop
        "DROP AGGREGATE IF EXISTS #{name} (#{input_data_type});"
      end
    end
  end
end
