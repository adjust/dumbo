module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      def warn(msg)
        return if msg =~ /^unknown OID/
        super
      end
    end
  end
end