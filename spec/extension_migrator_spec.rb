describe Dumbo::ExtensionMigrator do
  before(:all) do
    system('cd spec && make clean && make && make install')
  end
  after (:all) do
    system('cd spec && make clean && make uninstall')
  end

  let(:migrator){Dumbo::ExtensionMigrator.new('dumbo_sample','0.0.1','0.0.2')}

  it "should provide upgrade sql" do
    migrator.upgrade.should eq <<-SQL.gsub(/^ {4}/, '')
    ----functions----
    CREATE OR REPLACE FUNCTION foo(integer)
     RETURNS integer
     LANGUAGE plpgsql
     IMMUTABLE STRICT
    AS $function$
    BEGIN
      RETURN $1 + 10;
    END
    $function$
    SQL
  end

  it "should provide downgrade sql" do
    migrator.downgrade.should eq <<-SQL.gsub(/^ {4}/, '')
    ----functions----
    CREATE OR REPLACE FUNCTION foo(integer)
     RETURNS integer
     LANGUAGE plpgsql
     IMMUTABLE STRICT
    AS $function$
    BEGIN
      RETURN $1;
    END
    $function$
    SQL
  end
end