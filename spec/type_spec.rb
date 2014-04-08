require 'spec_helper'
describe Dumbo::Type do
  describe 'Base Type' do
    let(:type) do
      extension = Dumbo::Extension.new('hstore','1.1')
      extension.install
      extension.types.select{|t| t.name =='hstore'}.first
    end
    it "should have a sql representation" do
      type.to_sql.should eq <<-SQL.gsub(/^ {6}/, '')
      CREATE TYPE hstore(
        INPUT=hstore_in,
        OUTPUT=hstore_out,
        RECEIVE=hstore_recv,
        SEND=hstore_send,
        ANALYZE=-,
        CATEGORY='U',
        DEFAULT='',
        INTERNALLENGTH=-1,
        ALIGNMENT=int,
        STORAGE=EXTENDED
      );
      SQL
    end

    it 'should have a uniq identfier' do
      type.identify.should eq ['hstore']
    end
  end

  describe 'Composite Type' do
    let(:type) do
      sql "CREATE TYPE compfoo AS (f1 int, f2 text);"
      oid = sql("SELECT oid FROM pg_type where typname = 'compfoo'",'oid').first
      Dumbo::Type.new(oid).get
    end

    it "should have a sql representation" do
      type.to_sql.should eq <<-SQL.gsub(/^ {6}/, '')
      CREATE TYPE compfoo AS (
        f1 integer,
        f2 text
      );
      SQL
    end

    it 'should have a uniq identfier' do
      type.identify.should eq ['compfoo']
    end
  end

  describe 'Range Type' do
    let(:type) do
      sql "CREATE TYPE float8_range AS RANGE (subtype = float8, subtype_diff = float8mi);"
      oid = sql("SELECT oid FROM pg_type where typname = 'float8_range'",'oid').first
      Dumbo::Type.new(oid).get
    end

    it "should have a sql representation" do
      type.to_sql.should eq <<-SQL.gsub(/^ {6}/, '')
      CREATE TYPE float8_range AS RANGE (
        SUBTYPE=float8,
        SUBTYPE_OPCLASS=float8_ops,
        SUBTYPE_DIFF=float8mi
      );
      SQL
    end

    it 'should have a uniq identfier' do
      type.identify.should eq ['float8_range']
    end
  end

  describe 'Enum Type' do
    let(:type) do
      sql "CREATE TYPE bug_status AS ENUM ('new', 'open', 'closed');"
      oid = sql("SELECT oid FROM pg_type where typname = 'bug_status'",'oid').first
      Dumbo::Type.new(oid).get
    end

    it "should have a sql representation" do
      type.to_sql.should eq <<-SQL.gsub(/^ {6}/, '')
      CREATE TYPE bug_status AS ENUM (
        'new',
        'open',
        'closed'
      );
      SQL
    end

    it 'should have a uniq identfier' do
      type.identify.should eq ['bug_status']
    end
  end
end