require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

ENV['DUMBO_ENV'] ||= 'test'

task :default => :spec
