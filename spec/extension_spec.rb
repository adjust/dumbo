require 'spec_helper'
describe Dumbo::Extension do
  let(:extension){Dumbo::Extension.new('hstore','1.1')}
  before(:all) do
    Dumbo::Extension.new('hstore','1.1').install
  end

  it "should return extension obj_id" do
    extension.obj_id.should ~ /\d+/
  end

  it 'should return a list of objects' do
    extension.objects.size.should eq 86
  end

  it 'should return a list of types' do
    extension.types.select{|t| t.name == 'hstore'}.should_not be_empty
  end
end