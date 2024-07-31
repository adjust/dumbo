require 'rake'
require 'rake/tasklib'
require 'active_record'
require 'yaml'

module Dumbo
  class DbTask < ::Rake::TaskLib
    attr_accessor :name
    def initialize(name = 'db')
      @name = name

      namespace name do
        task environment: ['db:configure_connection']

        task :configuration do
          @config = YAML.load_file('config/database.yml')[ENV['DUMBO_ENV']]
        end

        task configure_connection: :configuration do
          ActiveRecord::Base.establish_connection @config
          ActiveRecord::Base.logger = Logger.new STDOUT if @config['logger']
        end

        desc 'Create the database from config/database.yml for the current ENV'
        task create: :environment do
          create_database @config
        end

        desc 'Drops the database for the current ENV'
        task drop: :environment do
          ActiveRecord::Base.establish_connection @config.merge('database' => nil)
          ActiveRecord::Base.connection.drop_database @config['database']
        end

        desc 'load db structure from db/structure.sql or DB_STRUCTURE environment variable'
        task load_structure: :environment do
            filename = ENV['DB_STRUCTURE'] || File.join('db', 'structure.sql')
            if File.exist?(filename)
              ActiveRecord::Tasks::DatabaseTasks.structure_load(@config, filename)
            else
              puts "File not found skip"
            end
          end

        namespace :test do
          task :environment do
            ENV['DUMBO_ENV'] = 'test'
            ActiveRecord::Schema.verbose = false
          end

          task load_structure: [:environment, 'db:load_structure']

          desc 'Re-create and prepare test database'
          task prepare: [:environment, :drop, :create]
        end
      end
    end

    def create_database(config)
      ActiveRecord::Base.establish_connection config.merge('database' => nil)
      ActiveRecord::Base.connection.create_database config['database'], config
      ActiveRecord::Base.establish_connection config
    end
  end
end
