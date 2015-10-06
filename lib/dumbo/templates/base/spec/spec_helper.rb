require "minitest/autorun"
require 'pg_spec'
require 'dumbo'

PgSpec.configure do |c|
  # c.con = PG.connect(
  #                    dbname: ENV['DUMBO_DB'],
  #                    user: ENV['DUMBO_USER'],
  #                    host: ENV['DUMBO_HOST'],
  #                    port: ENV['DUMBO_PORT']
  #                    )
  c.con = Dumbo.connection
  c.root = File.expand_path('../..',__FILE__)
  c.logdir = 'log'
  c.before(:suite) do
    c.con.exec "CREATE EXTENSION #{Dumbo::Extension.new.name}"
  end

  c.after(:suite) do
    c.con.exec "DROP EXTENSION #{Dumbo::Extension.new.name}"
  end
end

