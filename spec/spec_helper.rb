require "minitest/autorun"
require 'pg_spec'
require 'dumbo'
require 'support/extension_helper'

include ExtensionHelper

def query(sql)
  Dumbo.connection.exec(sql)
end