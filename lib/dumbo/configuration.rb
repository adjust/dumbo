module Dumbo
  class Configuration
    attr_accessor :dbname, :user, :host, :port, :root

    def initialize
      @user, @host, @port = 'postgres', 'localhost', '5432'
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