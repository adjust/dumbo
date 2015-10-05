require 'dumbo'
Dumbo.configure do |d|
  d.root = File.dirname(__FILE__)
  d.dbname = 'dumbo_test'
end
