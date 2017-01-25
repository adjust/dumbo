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

      # TODO this is likely obsolete - consider removing
      #
      # def structure_load(config, filename)
      #   ENV['PGHOST']     = config['host']          if config['host']
      #   ENV['PGPORT']     = config['port'].to_s     if config['port']
      #   ENV['PGPASSWORD'] = config['password'].to_s if config['password']
      #   ENV['PGUSER']     = config['username'].to_s if config['username']

      #   args = ['-v', 'ON_ERROR_STOP=1', '-q', '-f', filename]
      #   args << config['dbname']

      #   run_cmd('psql', args)
      # end

      # private

      # def run_cmd(cmd, args)
      #   fail run_cmd_error(cmd, args) unless Kernel.system(cmd, *args)
      # end

      # def run_cmd_error(cmd, args)
      #   msg = "failed to execute:\n"
      #   msg << "#{cmd} #{args.join(' ')}\n\n"
      #   msg << "Please check the output above for any errors and make sure that `#{cmd}` is installed in your PATH and has proper permissions.\n\n"
      #   msg
      # end
    end
  end
end
