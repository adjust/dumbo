require 'rake'
require 'rake/tasklib'
require 'pg'
module Dumbo
  class DbTask < ::Rake::TaskLib
    attr_accessor :name
    def initialize(name = 'db')
      @name = name

      namespace name do
        desc 'Create the database from config/database.yml for the current ENV'
        task :create do
          con = PG.connect config.merge(dbname: nil)
          con.exec  "CREATE DATABASE #{config[:dbname]}"
        end

        desc 'Drops the database for the current ENV'
        task :drop do
          con = PG.connect config.merge(dbname: nil)
          con.exec  "DROP DATABASE IF EXISTS #{config[:dbname]}"
        end

        desc 'load db structure from db/structure.sql or DB_STRUCTURE environment variable'
        task load_structure: :prepare do
            filename = ENV['DB_STRUCTURE'] || File.join('db', 'structure.sql')
            if File.exists?(filename)
              ENV['PGHOST']     = config[:host]          if config[:host]
              ENV['PGPORT']     = config[:port].to_s     if config[:port]
              ENV['PGPASSWORD'] = config[:password].to_s if config[:password]
              ENV['PGUSER']     = config[:user].to_s     if config[:user]
              Kernel.system("psql -X -q -f #{Shellwords.escape(filename)} #{configuration[:dbname]}")
            else
              puts "File not found skip"
            end
          end

        desc 'Re-create and prepare test database'
        task prepare: [:drop, :create]
      end
    end

    def config
      Dumbo.configuration.dbconfig
    end
  end
end
