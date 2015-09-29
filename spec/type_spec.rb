require 'spec_helper'

describe Dumbo::Type do
  before(:each) do |example|
    install_testing_extension
    extension.create
  end

  after(:each) do |example|
    uninstall_testing_extension
  end

  let(:version) { '0.0.3' }

  let(:extension) { Dumbo::Extension.new('dumbo_sample', version) }

  let(:type) do
    oid = query("SELECT oid FROM pg_type WHERE typname = '#{type_name}'").first['oid']
    Dumbo::Type.new(oid).get
  end

  describe 'Base Type' do
    let(:version) { '0.0.4' }

    let(:type_name) { 'elephant_base' }

    let(:type) { extension.types.select { |t| t.name == type_name }.first }

    it 'should have a sql representation' do
      exp = <<-SQL.gsub(/^ {6}/, '')
      CREATE TYPE elephant_base(
        INPUT=elephant_in,
        OUTPUT=elephant_out,
        RECEIVE=-,
        SEND=-,
        ANALYZE=-,
        CATEGORY='U',
        DEFAULT='',
        INTERNALLENGTH=-1,
        ALIGNMENT=int,
        STORAGE=PLAIN
      );
      SQL

      assert_equal exp, type.to_sql
    end

    it 'should be identifiable' do
      assert_equal [type_name], type.identify
    end
  end

  describe 'Composite Type' do
    let(:type_name) { 'elephant_composite' }

    it 'should have a sql representation' do
      exp = <<-SQL.gsub(/^ {6}/, '')
      CREATE TYPE elephant_composite AS (
        weight integer,
        name text
      );
      SQL

      assert_equal exp, type.to_sql
    end

    it 'should be identifiable' do
      assert_equal [type_name], type.identify
    end
  end

  describe 'Range Type' do
    let(:type_name) { 'elephant_range' }

    it 'should have a sql representation' do
      exp = <<-SQL.gsub(/^ {6}/, '')
      CREATE TYPE elephant_range AS RANGE (
        SUBTYPE=float8,
        SUBTYPE_OPCLASS=float8_ops,
        SUBTYPE_DIFF=float8mi
      );
      SQL

      assert_equal exp, type.to_sql
    end

    it 'should be identifiable' do
      assert_equal [type_name], type.identify
    end
  end

  describe 'Enum Type' do
    let(:type_name) { 'elephant_enum' }

    it 'should have a sql representation' do
      exp = <<-SQL.gsub(/^ {6}/, '')
      CREATE TYPE elephant_enum AS ENUM (
        'infant',
        'child',
        'adult'
      );
      SQL

      assert_equal exp, type.to_sql
    end

    it 'should be identifiable' do
      assert_equal [type_name], type.identify
    end
  end
end
