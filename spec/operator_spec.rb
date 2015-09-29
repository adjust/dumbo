require 'spec_helper'
describe Dumbo::Operator do
  let(:operator) do
    oid = query("SELECT oid FROM pg_operator WHERE oprname = '&&' AND format_type(oprleft,NULL) = 'box' AND format_type(oprright,NULL) ='box'").first['oid']
    Dumbo::Operator.new(oid).get
  end

  it 'should have a sql representation' do
    exp =  <<-SQL.gsub(/^ {4}/, '')
    CREATE OPERATOR && (
      PROCEDURE = box_overlap,
      LEFTARG = box,
      RIGHTARG = box,
      COMMUTATOR = &&,
      RESTRICT = areasel,
      JOIN = areajoinsel
    );
    SQL

    assert_equal exp, operator.to_sql
  end

  it 'should have a uniq identfier' do
    assert_equal ['&&', 'box', 'box'], operator.identify
  end

  it 'should have drop sql' do
    assert_equal 'DROP OPERATOR IF EXISTS && (box, box);', operator.drop
  end
end
