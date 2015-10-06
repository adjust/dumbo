require "minitest/autorun"
require 'pg_spec'
require 'dumbo'
require 'support/extension_helper'

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


def cli(*args)
  conf = if args.include?('new')
   {}
   else
    { destination_root: ROOT }
  end

  capture(:stdout) { Dumbo::Cli.start(args,conf) }
end
