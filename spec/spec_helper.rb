require "minitest/autorun"
require 'pg_spec'
require 'dumbo'
require 'support/extension_helper'
require File.expand_path '../../config', __FILE__

include ExtensionHelper

ROOT =  File.expand_path '../../foo', __FILE__

def query(sql)
  Dumbo.connection.exec(sql)
end

# capture method from https://github.com/wycats/thor/blob/master/spec/spec_helper.rb#L36-47
def capture(stream)
  begin
    stream = stream.to_s
    eval "$#{stream} = StringIO.new"
    yield
    result = eval("$#{stream}").string
  ensure
    eval("$#{stream} = #{stream.upcase}")
  end

  result
end



def next_extension
  $counter += 1
  "extension.#{$counter}"
end

def cli(*args)
  capture(:stdout) { Dumbo::Cli.start(args) }
end

def change(extension_name, args=nil)
  #run_pgxn_utils(:skeleton, "#{extension_name} #{args}")
end

def run_pgxn_utils(task, args)
  #system "#{BIN_PATH} #{task.to_s} #{args}"
end
