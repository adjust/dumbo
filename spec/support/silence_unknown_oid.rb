module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      module DatabaseStatements
        def warn(msg)
          return if msg =~ /^unknown OID:/
          super
        end
      end
    end
  end
end