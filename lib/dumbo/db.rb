require 'pg'

# A wrapper class around the PG lib
module Dumbo
  class DB
    class Rollback < StandardError
    end

    class ConnectionNotSetup < StandardError
      def initialize
        super 'Postgres connection must be setup first'
      end
    end

    class << self
      def connect(config)
        @_connection ||= PG.connect(config)
      rescue PG::ConnectionBad => e
        false
      end

      def connection
        raise ConnectionNotSetup if @_connection.nil?

        @_connection
      end

      def exec(sql)
        connection.exec(sql)
      rescue PG::Error => e
        $stderr.puts("Error executing SQL:\n\n#{sql}\n\n#{e.inspect}")
        Kernel.exit 1
      end

      def transaction(&block)
        begin
          connection.transaction &block
        rescue DB::Rollback
        end
      end
    end
  end
end
