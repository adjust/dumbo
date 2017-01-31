module Dumbo
  module PgObject
    module Type
      class Base < Dumbo::PgObject::Base
        attr_accessor :name, :type, :typrelid

        identfied_by :name

        def load_attributes
          result = DB.exec("SELECT typname, typtype, typrelid FROM pg_type WHERE oid = #{oid}").first
          @name = result['typname']
          @type = result['typtype']
          @typrelid = result['typrelid']
        end

        def get
          case type
          when 'c'
            PgObject::Type::CompositeType.new(oid)
          when 'b'
            PgObject::Type::BaseType.new(oid)
          when 'r'
            PgObject::Type::RangeType.new(oid)
          when 'e'
            PgObject::Type::EnumType.new(oid)
          end
        end

        def drop
          "DROP TYPE IF EXISTS #{name};"
        end
      end
    end
  end
end
