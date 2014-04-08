require 'yaml'
require 'logger'
require 'active_record'

task environment: ['db:configure_connection' ]

task :test_env do
  ENV['DUMBO_ENV'] = 'test'
end

namespace :db do
  def create_database(config)
    ActiveRecord::Base.establish_connection config.merge('database' => nil)
    ActiveRecord::Base.connection.create_database config['database'], config
    ActiveRecord::Base.establish_connection config
  end

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

  namespace :test do
    task :environment do
      ENV['DUMBO_ENV'] ||= 'test'
      ActiveRecord::Schema.verbose = false
    end

    task load_structure: :environment do
      filename = ENV['DB_STRUCTURE'] || File.join("db", "structure.sql")
      ActiveRecord::Tasks::DatabaseTasks.structure_load(@config, filename)
    end

    desc "Re-create and prepare test database"
    task prepare: [:environment, :drop, :create]
  end
end
