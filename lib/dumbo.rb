require 'thor'
require 'erubis'
require 'fileutils'
require 'pathname'

['', 'command', 'pg_object', 'pg_object/type'].each do |submodule|
  Dir.glob(File.join(File.dirname(__FILE__), 'dumbo', submodule, '*.rb')).each do |path|
    require File.expand_path(path)
  end
end

module Dumbo
  class << self
    def in_extension_directory?
      Extension.name && Extension.version
    end

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

    def init(env)
      return false if db_config.nil? || db_config[env].nil?

      DB.connect(db_config[env])
    end

    def db_config
      return nil unless File.exists?(Extension.config_file)

      @config ||= YAML.load_file(Extension.config_file)
    end

    # This is meant to enable possible future functionality such as flexible
    # extension root via environment variable or config.
    def extension_root
      FileUtils.pwd
    end

    def connstring(env)
      return nil if db_config.nil?

      db_config[env].map { |key, value| "#{key}=#{value}" }.join(' ')
    end
  end
end
