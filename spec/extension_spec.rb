require 'spec_helper'

describe Dumbo::Extension do
  describe 'extension setup' do
    let(:extension) { Dumbo::Extension.new('hstore', '1.1') }

    before(:all) do
      Dumbo::Extension.new('hstore', '1.1').install
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

  describe '#available_versions' do
    let(:releases) do
      [ 'ext--abc.sql', 'ext--0.10.7.sql', 'ext--0.11.0.sql',
        'ext--1.0.0.sql', 'ext--0.12.sql', 'ext--0.10.5.sql' ]
    end

    before do
      described_class.any_instance.stub(:releases).and_return(releases)
    end

    subject { described_class.new('', '').available_versions.map(&:to_s) }

    it { should match_array [ '0.10.5', '0.10.7', '0.11.0', '0.12', '1.0.0' ] }
  end
end
