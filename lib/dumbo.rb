require 'thor'
require 'erubis'
require 'fileutils'
require 'pathname'

['', 'command', 'pg_object', 'pg_object/type'].each do |submodule|
  Dir.glob("#{File.dirname(__FILE__)}/dumbo/#{submodule}/*.rb").each do |path|
    require File.expand_path(path)
  end
end

module Dumbo
  class NoConfigurationError < StandardError
    def initialize(env)
      super "Config for environment #{env} not found"
    end
  end

  class << self
    def extension_file(*files)
      File.join(extension_root, *files)
    end

    def extension_files(*files)
      Dir.glob(extension_file(*files))
    end

    def template_root
      File.join(File.dirname(__FILE__), '..', 'template')
    end

    def template_files(*files)
      Dir.glob(File.join(template_root, *files))
    end

    def boot(env)
      raise NoConfigurationError.new(env) if db_config[env].nil?

      if !DB.connect(db_config[env])
        $stderr.puts("Error connecting to PostgreSQL using connection string: `#{connstring(env)}`.")
        return false
      end

      true
    end

    def db_config
      @config ||= YAML.load_file(File.join('config', 'database.yml'))
    end

    # This is meant to enable possible future functionality such as flexible
    # extension root via environment variable or config.
    def extension_root
      FileUtils.pwd
    end

    private

    def connstring(env)
      db_config[env].map { |key, value| "#{key}=#{value}" }.join(' ')
    end
  end
end
