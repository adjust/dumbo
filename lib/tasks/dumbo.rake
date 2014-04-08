require 'erubis'
require 'pathname'

task :default => ['dumbo:all', :spec]

namespace :dumbo do
  include Dumbo::RakeHelper

  task :all => ["#{extension}--#{version}.sql", :install]

  desc 'installs the extension'
  task :install do
    system('make clean && make && make install')
  end

  desc 'concatenates files'
  file "#{extension}--#{version}.sql" => file_list do |t|
    sql = t.prerequisites.map do |file|
      ["--source file #{file}"] + get_sql(file) + [" "]
    end.flatten
    concatenate sql, t.name
  end
end