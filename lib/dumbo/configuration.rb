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
      @connection ||= PG.connect(dbconfig)
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
  end
end