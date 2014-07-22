require 'spec_helper'
describe Dumbo::Operator do
  let(:operator) do
    oid = query("SELECT oid FROM pg_operator WHERE oprname = '&&' AND format_type(oprleft,NULL) = 'box' AND format_type(oprright,NULL) ='box'").first['oid']
    Dumbo::Operator.new(oid).get
  end

  it 'should have a sql representation' do
    operator.to_sql.should eq <<-SQL.gsub(/^ {4}/, '')
    CREATE OPERATOR && (
      PROCEDURE = box_overlap,
      LEFTARG = box,
      RIGHTARG = box,
      COMMUTATOR = &&,
      RESTRICT = areasel,
      JOIN = areajoinsel
    );
    SQL
  end

  it 'should have a uniq identfier' do
    operator.identify.should eq ['&&', 'box', 'box']
  end

  it 'should have upgrade sql' do
    operator.upgrade(nil).should eq <<-SQL.gsub(/^ {4}/, '')
    CREATE OPERATOR && (
      PROCEDURE = box_overlap,
      LEFTARG = box,
      RIGHTARG = box,
      COMMUTATOR = &&,
      RESTRICT = areasel,
      JOIN = areajoinsel
    );
    SQL
  end

  it 'should have downgrade sql' do
    operator.downgrade(nil).should eq 'DROP OPERATOR &&;'
  end
end
