require 'rake'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'dumbo/db_task'
require 'dumbo'

task :default => ['db:prepare', :test]

Dumbo::DbTask.new(:db)

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
  t.libs << 'spec'
  t.libs << 'spec/support'
end

Dumbo.configure do |d|
  d.dbname = 'dumbo_test'
end
