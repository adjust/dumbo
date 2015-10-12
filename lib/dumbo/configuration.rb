module Dumbo
  class Configuration
    attr_accessor :dbname, :user, :host, :port

    def initialize
      @dbname = ENV['DUMBO_DB']   || "contrib_regression"
      @port   = ENV['DUMBO_PORT'] || "5432"
      @user   = ENV['DUMBO_USER'] || "postgres"
      @host   = ENV['DUMBO_HOST'] || "localhost"
    end

    def connection
      unless @connection
        @connection = PG.connect(dbconfig)
        @connection.exec "SET client_min_messages TO warning"
      end

      @connection
    end

    def connection_reset
      @connection.close if @connection
      @connection = nil
    end

    def dbconfig
      {dbname: dbname, user: user, host: host, port: port}
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
    configuration.connection_reset
  end
end