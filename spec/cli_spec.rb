require 'pry'
require 'spec_helper'

describe "dumbo new" do

  before do
    Dir.chdir File.expand_path '../..', __FILE__
    `rm -rf #{ROOT}`
    ENV['DUMBO_DB'] = "foo_test"
  end

  after do
    Dir.chdir File.expand_path '../..', __FILE__
    `rm -rf #{ROOT}`
    ENV['DUMBO_DB'] = ENV['TEST_DB'] || "dumbo_test"
  end

  it 'should generate a skeleton with template c if -t set' do
    %x{dumbo new foo -t=c}
    assert $?.success?
    assert File.exist?('foo/src/foo.c')
  end

  it 'should generate a skeleton with template sql by default' do
    %x{dumbo new foo}
    assert $?.success?
    assert !File.exist?('foo/src/foo.c')
    assert File.exist?('foo/sql/sample.sql')
  end

  describe 'with an extension foo' do
    before do
      %x{dumbo new foo}
      assert $?.success?
      assert $?.success?
      Dir.chdir ROOT
    end
    it 'should build extension sql' do
      b = %x{dumbo build}
      assert $?.success?
      cr = b.split("\n").first.strip
      assert_equal 'create  foo--0.0.1.sql', cr
      assert File.exist?("foo--0.0.1.sql")
    end

    it 'should bump version' do
      %x{dumbo bump major}
      assert $?.success?
      assert File.exist?('foo.control')
      assert File.read('foo.control').include?("default_version = '1.0.0'")
    end

    it 'should create regression tests' do
      assert !File.exist?('test/sql/foo_spec.sql')
      %x{dumbo regress}
      assert $?.success?
      assert File.exist?('test/sql/foo_spec.sql')
    end
  end
end