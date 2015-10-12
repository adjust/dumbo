require 'pry'
require 'spec_helper'

describe "dumbo new" do

  before do
    Dir.chdir File.expand_path '../..', __FILE__
    `rm -rf #{ROOT}`
    # ENV['DUMBO_DB'] = "foo_test"
  end

  after do
    Dir.chdir File.expand_path '../..', __FILE__
    `rm -rf #{ROOT}`
    # ENV['DUMBO_DB'] = ENV['TEST_DB'] || "dumbo_test"
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
      Dir.chdir ROOT
    end

    it 'should run default tests' do
      b = %x{dumbo test}
      assert $?.success?
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

    it "should create migration files" do
      %x{dumbo build}
      assert $?.success?
      %x{dumbo bump major}
      assert $?.success?
      func = <<-SQL
      CREATE FUNCTION bar_99(int) RETURNS int AS $$
      SELECT $1 + 99;
      $$ LANGUAGE SQL IMMUTABLE STRICT;
      SQL
      File.open('sql/bar_99.sql','w'){|f| f.puts func}
      %x{dumbo migrations}
      assert $?.success?
      assert File.exist?("foo--0.0.1.sql")
      assert File.exist?("foo--1.0.0.sql")
      assert File.exist?("foo--0.0.1--1.0.0.sql")
      assert File.exist?("foo--1.0.0--0.0.1.sql")
      assert_includes File.read("foo--1.0.0--0.0.1.sql"), "DROP FUNCTION IF EXISTS bar_99(integer);"
      assert_includes File.read("foo--0.0.1--1.0.0.sql"), "CREATE OR REPLACE FUNCTION bar_99(integer)"
    end

    it 'can template sql files' do
      func = <<-SQL
      --load config/num
      <% numbers.each do |n|%>
      CREATE FUNCTION bar_<%=n%>(int) RETURNS int AS $$
      SELECT $1 + 99;
      $$ LANGUAGE SQL IMMUTABLE STRICT;
      <% end %>
      SQL

      conf = <<-YAML
      numbers:
        - 1
        - 2
        - 3
      YAML

      File.open('sql/num.sql.tt','w'){|f| f.puts func}
      Dir.mkdir('config')
      File.open('config/num.yml','w'){|f| f.puts conf}
      %x{dumbo build}
      assert $?.success?
      assert_includes File.read("foo--0.0.1.sql"), "CREATE FUNCTION bar_1(int)"
      assert_includes File.read("foo--0.0.1.sql"), "CREATE FUNCTION bar_2(int)"
      assert_includes File.read("foo--0.0.1.sql"), "CREATE FUNCTION bar_3(int)"
    end

  end
end