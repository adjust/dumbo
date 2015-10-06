require 'spec_helper'

describe "dumbo new" do

  def setup
    `rm -rf #{ROOT}`
  end

  def teardown
    # `rm -rf #{ROOT}`
  end

  it 'should generate a skeleton with template c if -t set' do
    cli 'new', 'foo', '-t=c'
    assert File.exist?('foo/src/foo.c')
  end

  it 'should generate a skeleton with template sql by default' do
    cli 'new', 'foo'
    assert !File.exist?('foo/src/foo.c')
  end

  it 'should pass the tests by default' do
    # Dumbo.configure{|c| c.dbname='foo_test'}
    # cli 'new', 'foo'
    # cli 'test'
  end
end