module Dumbo
  class Type < PgObject
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
        Types::CompositeType.new(oid)
      when 'b'
        Types::BaseType.new(oid)
      when 'r'
        Types::RangeType.new(oid)
      when 'e'
        Types::EnumType.new(oid)
      end
    end

    def drop
      "DROP TYPE IF EXISTS #{name};"
    end
  end
end
