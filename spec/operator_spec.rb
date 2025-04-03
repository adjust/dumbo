require 'spec_helper'
describe Dumbo::Operator do
  let(:operator) do
    oid = query("SELECT oid FROM pg_operator WHERE oprname = '&&' AND format_type(oprleft,NULL) = 'box' AND format_type(oprright,NULL) ='box'").first['oid']
    Dumbo::Operator.new(oid).get
  end

  it 'should have a sql representation' do
    expect(operator.to_sql).to eq <<-SQL.gsub(/^ {4}/, '')
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
    expect(operator.identify).to eq ['&&', 'box', 'box']
  end

  it 'should have drop sql' do
    expect(operator.drop).to eq 'DROP OPERATOR IF EXISTS && (box, box);'
  end
end
