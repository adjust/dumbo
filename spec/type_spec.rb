require 'spec_helper'

describe Dumbo::PgObject::Type do
  around(:each) do |example|
    install_testing_extension
    extension.create
    example.run
    uninstall_testing_extension
  end

  let(:version) { '0.0.3' }

  let(:extension) { Dumbo::Extension.new('dumbo_sample', version) }

  let(:type) do
    oid = Dumbo::DB.exec("SELECT oid FROM pg_type WHERE typname = '#{type_name}'").first['oid']
    described_class::Base.new(oid).get
  end

  shared_examples_for 'identifiable' do
    subject { type.identify }

    it { should eq [type_name] }
  end

  describe 'Base Type' do
    let(:version) { '0.0.4' }

    let(:type_name) { 'elephant_base' }

    let(:type) { extension.types.select { |t| t.name == type_name }.first }

    it 'should have a sql representation' do
      expect(type.to_sql).to eq_sql <<-SQL
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
    end

    it_should_behave_like 'identifiable'
  end

  describe 'Composite Type' do
    let(:type_name) { 'elephant_composite' }

    it 'should have a sql representation' do
      expect(type.to_sql).to eq_sql <<-SQL
        CREATE TYPE elephant_composite AS (
          weight integer,
          name text
        );
      SQL
    end

    it_should_behave_like 'identifiable'
  end

  describe 'Range Type' do
    let(:type_name) { 'elephant_range' }

    it 'should have a sql representation' do
      expect(type.to_sql).to eq_sql <<-SQL
        CREATE TYPE elephant_range AS RANGE (
          SUBTYPE=float8,
          SUBTYPE_OPCLASS=float8_ops,
          SUBTYPE_DIFF=float8mi
        );
      SQL
    end

    it_should_behave_like 'identifiable'
  end

  describe 'Enum Type' do
    let(:type_name) { 'elephant_enum' }

    it 'should have a sql representation' do
      expect(type.to_sql).to eq_sql <<-SQL
        CREATE TYPE elephant_enum AS ENUM (
          'infant',
          'child',
          'adult'
        );
      SQL
    end

    it_should_behave_like 'identifiable'
  end
end
