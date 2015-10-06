require 'pg'
require 'dumbo/version'
require 'dumbo/cli'
require 'dumbo/pg_object'
require 'dumbo/type'
require 'dumbo/function'
require 'dumbo/cast'
require 'dumbo/base_type'
require 'dumbo/aggregate'
require 'dumbo/composite_type'
require 'dumbo/dependency_resolver'
require 'dumbo/enum_type'
require 'dumbo/extension'
require 'dumbo/extension_migrator'
require 'dumbo/extension_version'
require 'dumbo/operator'
require 'dumbo/range_type'
require 'dumbo/configuration'
require 'dumbo/binding_loader'

module Dumbo

  def self.connection
    configuration.connection
  end
end
