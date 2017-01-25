require 'dumbo/version'
require 'dumbo/db'
require 'dumbo/pg_object'
require 'dumbo/cli'
require 'dumbo/type'
require 'dumbo/types/composite_type'
require 'dumbo/types/enum_type'
require 'dumbo/types/range_type'
require 'dumbo/types/base_type'
require 'dumbo/function'
require 'dumbo/cast'
require 'dumbo/aggregate'
require 'dumbo/dependency_resolver'
require 'dumbo/extension'
require 'dumbo/extension_migrator'
require 'dumbo/extension_version'
require 'dumbo/operator'
require 'dumbo/version'
require 'dumbo/binding_loader'

module Dumbo
  class NoConfigurationError < StandardError
    def initialize(env)
      super "Config for environment #{env} not found"
    end
  end

  class << self
    def boot(env)
      raise NoConfigurationError.new(env) if db_config[env].nil?

      DB.connect db_config[env]
    end

    def db_config
      @config ||= YAML.load_file(File.join('config', 'database.yml'))
    end
  end
end
