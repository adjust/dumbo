require "minitest/autorun"
require 'pg_spec'
require 'dumbo'
require 'support/extension_helper'
require File.expand_path '../../config', __FILE__

include ExtensionHelper

puts Dumbo.configuration.dbconfig
def query(sql)
  Dumbo.connection.exec(sql)
end