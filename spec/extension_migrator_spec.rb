require 'spec_helper'

describe Dumbo::ExtensionMigrator do
  after(:each) do |example|
    uninstall_testing_extension
  end

  before(:each) do |example|
    install_testing_extension
  end


  let(:migrator) { Dumbo::ExtensionMigrator.new('dumbo_sample', '0.0.1', '0.0.2') }

  it 'should provide upgrade sql' do
    exp = <<-SQL.gsub(/^ {4}/, '').strip
    ----functions----
    CREATE OR REPLACE FUNCTION foo(integer)
     RETURNS integer
     LANGUAGE plpgsql
     IMMUTABLE STRICT
    AS $function$
    BEGIN
      RETURN $1 + 10;
    END
    $function$;
    SQL

    assert_equal exp, migrator.upgrade
  end

  it 'should provide downgrade sql' do
    exp = <<-SQL.gsub(/^ {4}/, '').strip
    ----functions----
    CREATE OR REPLACE FUNCTION foo(integer)
     RETURNS integer
     LANGUAGE plpgsql
     IMMUTABLE STRICT
    AS $function$
    BEGIN
      RETURN $1;
    END
    $function$;
    SQL

    assert_equal exp, migrator.downgrade
  end
end
