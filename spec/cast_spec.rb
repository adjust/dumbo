require 'spec_helper'

describe Dumbo::Cast do
  let(:cast) do
    sql = <<-SQL
      SELECT ca.oid
      FROM pg_cast ca
      JOIN pg_type st ON st.oid=castsource
      JOIN pg_type tt ON tt.oid=casttarget
      WHERE format_type(st.oid,NULL) = 'bigint'
      AND format_type(tt.oid,tt.typtypmod) = 'integer'
    SQL

    Dumbo::Cast.new(Dumbo::DB.exec(sql).first['oid'])
  end

  it 'should have a sql representation' do
    expect(cast.to_sql).to eq_sql <<-SQL
      CREATE CAST (bigint AS integer)
      WITH FUNCTION int4(bigint)
      AS ASSIGNMENT;
    SQL
  end
end
