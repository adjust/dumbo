require 'spec_helper'
describe Dumbo::Aggregate do
  let(:avg) do
    oid = sql("SELECT p.oid
              FROM pg_proc p
              JOIN pg_aggregate ag ON p.oid = ag.aggfnoid
              WHERE proname='avg' AND pg_get_function_arguments(p.oid) = 'integer'",'oid').first
    Dumbo::Aggregate.new(oid)
  end

  let(:min) do
    oid = sql("SELECT p.oid
              FROM pg_proc p
              JOIN pg_aggregate ag ON p.oid = ag.aggfnoid
              WHERE proname='min' AND pg_get_function_arguments(p.oid) = 'integer'",'oid').first
    Dumbo::Aggregate.new(oid)
  end


  it "avg should have a sql representation" do
      avg.to_sql.should eq <<-SQL.gsub(/^ {6}/, '')
      CREATE AGGREGATE avg(integer) (
        SFUNC = int4_avg_accum,
        STYPE = int8[],
        FINALFUNC = int8_avg,
        INITCOND = '{0,0}'
      );
      SQL
  end

  it "min should have a sql representation" do
      min.to_sql.should eq <<-SQL.gsub(/^ {6}/, '')
      CREATE AGGREGATE min(integer) (
        SFUNC = int4smaller,
        STYPE = int4,
        SORTOP = <
      );
      SQL
  end

end