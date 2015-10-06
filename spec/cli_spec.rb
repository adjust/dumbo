require 'pry'
require 'spec_helper'

describe "dumbo new" do

  before do
    `rm -rf #{ROOT}`
    Dumbo.configure{|c| c.dbname = "foo_test"}
    ENV['DUMBO_DB'] = "foo_test"
  end

  after do
    `rm -rf #{ROOT}`
    Dumbo.configure{|c| c.dbname = ENV['TEST_DB'] || "contrib_regression"}
    ENV['DUMBO_DB'] = ENV['TEST_DB'] || "contrib_regression"
  end

  it 'should generate a skeleton with template c if -t set' do
    cli 'new', 'foo', '-t=c'
    assert File.exist?('foo/src/foo.c')
  end

  it 'should generate a skeleton with template sql by default' do
    cli 'new', 'foo'
    assert !File.exist?('foo/src/foo.c')
  end

  it 'should build extension sql' do
    cli 'new', 'foo'
    b = cli 'build'
    cr = b.split("\n").first.strip
    assert_equal 'create  foo--0.0.1.sql', cr
    assert File.exist?("foo/foo--0.0.1.sql")
  end

  it 'should bump version' do
    cli 'new', 'foo'
    cli 'bump', 'major'
    assert File.exist?('foo/foo.control')
    assert File.read('foo/foo.control').include?("default_version = '1.0.0'")
  end

  it 'should create regression tests' do
    cli 'new', 'foo'
    assert !File.exist?('foo/test/sql/foo_spec.sql')
    cli 'regress'
    assert File.exist?('foo/test/sql/foo_spec.sql')
  end
end