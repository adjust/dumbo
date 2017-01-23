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
      end

      def connection
        raise ConnectionNotSetup if @_connection.nil?

        @_connection
      end

      def exec(sql)
        connection.exec(sql)
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
