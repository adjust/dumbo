require 'spec_helper'
describe Dumbo::Cast do
  let(:cast) do
    oid = sql("SELECT ca.oid
              FROM pg_cast ca
              JOIN pg_type st ON st.oid=castsource
              JOIN pg_type tt ON tt.oid=casttarget
              WHERE  format_type(st.oid,NULL) = 'bigint'
                AND format_type(tt.oid,tt.typtypmod) = 'integer';",'oid').first
    Dumbo::Cast.new(oid)
  end

  it "should have a sql representation" do
      cast.to_sql.should eq <<-SQL.gsub(/^ {6}/, '')
      CREATE CAST (bigint AS integer)
      WITH FUNCTION int4(bigint)
      AS ASSIGNMENT;
      SQL
    end
end