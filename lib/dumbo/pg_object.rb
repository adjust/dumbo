require 'active_support/core_ext/class/attribute'

module Dumbo
  class PgObject
    attr_reader :oid
    class_attribute :identifier

    class << self
      def identfied_by(*args)
        self.identifier = args
      end
    end

    def initialize(oid)
      @oid = oid
      load_attributes
    end

    def identify
       identifier.map{|a| public_send a}
    end

    def get(type=nil)
      case type
      when 'function', 'pg_proc'
        Function.new(oid).get
      when 'cast', 'pg_cast'
        Cast.new(oid).get
      when 'operator', 'pg_operator'
        Operator.new(oid).get
      when 'type', 'pg_type'
        Type.new(oid).get
      else
        self.load_attributes
        self
      end
    end

    def load_attributes

    end

    def upgrade(other)
      return self.to_sql if other.nil?

      if other.identify != self.identify
        raise "Not the Same Objects!"
      end

      if other.to_sql != self.to_sql
         <<-SQL.gsub(/^ {8}/, '')
        #{self.drop}
        #{self.to_sql}
        SQL
      end


    end

    def downgrade(other)
      return self.drop if other.nil?

      if other.identify != self.identify
        raise "Not the Same Objects!"
      end

      if other.to_sql != self.to_sql
         <<-SQL.gsub(/^ {8}/, '')
        #{self.drop}
        #{other.to_sql}
        SQL
      end
    end

    def execute(sql)
      ActiveRecord::Base.connection.execute(sql)
    end

  end
end