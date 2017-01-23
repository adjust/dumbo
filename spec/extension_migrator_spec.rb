require 'spec_helper'

describe Dumbo::ExtensionMigrator do
  around(:each) do |example|
    install_testing_extension
    example.run
    uninstall_testing_extension
  end

  let(:migrator) { Dumbo::ExtensionMigrator.new('dumbo_sample', '0.0.1', '0.0.2') }

  it 'should provide upgrade sql' do
    expect(migrator.upgrade).to eq_sql <<-SQL
      ----functions----
      CREATE OR REPLACE FUNCTION foo(integer)
      RETURNS integer
      LANGUAGE plpgsql IMMUTABLE STRICT
      AS $function$
      BEGIN
        RETURN $1 + 10;
      END
      $function$;
    SQL
  end

  it 'should provide downgrade sql' do
    expect(migrator.downgrade).to eq_sql <<-SQL
      ----functions----
      CREATE OR REPLACE FUNCTION foo(integer)
      RETURNS integer
      LANGUAGE plpgsql IMMUTABLE STRICT
      AS $function$
      BEGIN
        RETURN $1;
      END
      $function$;
    SQL
  end
end
