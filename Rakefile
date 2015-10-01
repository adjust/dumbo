require 'rake'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'dumbo/db_task'
require 'dumbo'
require File.expand_path '../config', __FILE__

Dumbo::DbTask.new(:db)

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
  t.libs << 'spec'
end

task :default => ['db:prepare', :test]