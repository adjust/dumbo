require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'dumbo/db_task'

RSpec::Core::RakeTask.new(:spec)
Dumbo::DbTask.new(:db)

task :default => ['db:test:prepare', :spec]
