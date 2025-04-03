module Dumbo
  class Function < PgObject
    attr_accessor :name, :result_type, :definition, :type, :arg_types
    identfied_by :name, :arg_types

    def initialize(oid)
      super
      get
    end

    def get
      if type == 'agg'
        Aggregate.new(oid)
      else
        self
      end
    end

    def drop
      "DROP FUNCTION IF EXISTS #{name}(#{arg_types});"
    end

    def migrate_to(other)

      if other.identify != identify
        fail 'Not the Same Objects!'
      end

      return nil if other.to_sql == to_sql

      if other.result_type != result_type
        <<-SQL.gsub(/^ {8}/, '')
        #{drop}
        #{other.to_sql}
        SQL
      else
        other.to_sql
      end
    end

    def load_attributes
      result = execute <<-SQL
        SELECT
          p.proname as name,
          pg_catalog.pg_get_function_result(p.oid) as result_type,
          pg_catalog.pg_get_function_arguments(p.oid) as args,
          pg_catalog.pg_get_function_identity_arguments(p.oid) as arg_types,
           CASE p.prokind
              WHEN 'a' THEN 'agg'
              WHEN 'w' THEN 'window'
              WHEN 'p' THEN 'proc'
              ELSE 
                CASE WHEN p.prorettype = 'pg_catalog.trigger'::pg_catalog.regtype 
                  THEN 'trigger' 
                  ELSE 'normal' 
                END
           END as "type",
          CASE
            WHEN p.provolatile = 'i' THEN 'immutable'
            WHEN p.provolatile = 's' THEN 'stable'
            WHEN p.provolatile = 'v' THEN 'volatile'
          END as volatility,
          proisstrict as is_strict,
          l.lanname as language,
          p.prosrc as "source",
          pg_catalog.obj_description(p.oid, 'pg_proc') as description,
          CASE WHEN  p.prokind = 'a' THEN 'agg_dummy' ELSE pg_get_functiondef(p.oid) END as definition

        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_language l ON l.oid = p.prolang
        WHERE pg_catalog.pg_function_is_visible(p.oid)
          AND p.oid = #{oid};
      SQL

      result.first.each do |k, v|
        send("#{k}=", v) rescue nil
      end

      result.first
    end

    def to_sql
      definition.gsub("public.#{name}", name).strip + ';'
    end
  end
end
