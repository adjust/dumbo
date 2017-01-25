require 'singleton'

module Dumbo
  class PgObject
    class Unregistered < StandardError
      def initialize
        super 'PgObject classes must declare `identified_by` parameters'
      end
    end

    class Registry
      include ::Singleton

      attr_reader :identifiers

      class << self
        def identifiers
          instance.identifiers
        end

        def identifier(klass)
          klass.ancestors.each do |ancestor|
            identifier = instance.identifiers[ancestor]

            return identifier unless identifier.nil?
          end

          raise PgObject::Unregistered
        end
      end

      def identifiers
        @identifiers ||= {}
      end
    end

    attr_reader :oid

    def self.identfied_by(*args)
      Registry.identifiers[self] = args
    end

    def initialize(oid)
      @oid = oid
      load_attributes
    end

    def identifier
      Registry.identifier(self.class)
    end

    def identify
      identifier.map { |a| public_send a }
    end

    def get(type = nil)
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
        load_attributes
        self
      end
    end

    def load_attributes
    end

    def migrate_to(other)
      fail 'Not the Same Objects!' unless other.identify == identify

      if other.to_sql != to_sql
        <<-SQL.gsub(/^ {8}/, '')
        #{drop}
        #{other.to_sql}
        SQL
      end
    end
  end
end
