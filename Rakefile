require 'rake'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'dumbo'

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
  t.libs << 'spec'
end

task :default => ['db_prepare', :test, :cleanup]

task :db_prepare do
  con = PG.connect config.merge(dbname: nil)
  con.exec  "DROP DATABASE IF EXISTS #{config[:dbname]}"
  con.exec  "CREATE DATABASE #{config[:dbname]}"
end

task :cleanup do
  con = PG.connect config.merge(dbname: nil)
  con.exec  "DROP DATABASE IF EXISTS #{config[:dbname]}"
end

def config
  Dumbo.configuration.dbconfig
end