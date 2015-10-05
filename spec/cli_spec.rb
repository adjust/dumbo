require 'spec_helper'

describe "dumbo new" do

  def setup
    `rm -r #{ROOT}`
  end

  def teardown

  end

  it 'should generate a skeleton with template c if -t set' do
    cli 'new', 'foo', '-t=c'
    assert File.exist?('foo/src/foo.c')
  end

  it 'should generate a skeleton with template sql by default' do
    cli 'new', 'foo'
    assert !File.exist?('foo/src/foo.c')
  end
end