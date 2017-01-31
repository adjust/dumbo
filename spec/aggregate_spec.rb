require 'spec_helper'

describe Dumbo::PgObject::Aggregate do
  let(:avg) do
    sql = <<-SQL
      SELECT p.oid
      FROM pg_proc p
      JOIN pg_aggregate ag ON p.oid = ag.aggfnoid
      WHERE proname='avg' AND pg_get_function_arguments(p.oid) = 'integer'
    SQL

    described_class.new(Dumbo::DB.exec(sql).first['oid'])
  end

  let(:min) do
    sql = <<-SQL
      SELECT p.oid
      FROM pg_proc p
      JOIN pg_aggregate ag ON p.oid = ag.aggfnoid
      WHERE proname='min' AND pg_get_function_arguments(p.oid) = 'integer'
    SQL

    described_class.new(Dumbo::DB.exec(sql).first['oid'])
  end

  it 'avg should have a sql representation' do
    expect(avg.to_sql).to eq_sql <<-SQL
      CREATE AGGREGATE avg(integer) (
        SFUNC = int4_avg_accum,
        STYPE = int8[],
        FINALFUNC = int8_avg,
        INITCOND = '{0,0}'
      );
    SQL
  end

  it 'min should have a sql representation' do
    expect(min.to_sql).to eq_sql <<-SQL
      CREATE AGGREGATE min(integer) (
        SFUNC = int4smaller,
        STYPE = int4,
        SORTOP = "<"
      );
    SQL
  end
end
