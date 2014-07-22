require 'spec_helper'
include ExtensionHelper
describe Dumbo::Extension do
  describe 'extension setup' do
    let(:extension) { described_class.new('dumbo_sample', '0.0.3') }

    around(:each) do |example|
      install_testing_extension
      extension.create
      example.run
      uninstall_testing_extension
    end

    it 'should return extension obj_id' do
      extension.obj_id.should ~ /\d+/
    end

    it 'should return a list of objects' do
      extension.objects.should have(5).items
    end

    describe 'handling types' do
      let(:names) { %w(elephant_composite elephant_range elephant_enum) }

      let(:classes) { [Dumbo::EnumType, Dumbo::CompositeType, Dumbo::RangeType] }

      subject { extension.types }

      it { subject.map(&:class).should match_array classes }
      it { subject.map(&:name).should match_array names }
    end
  end

  describe '#versions' do
    let(:releases) do
      ['ext--abc.sql', 'ext--0.10.7.sql', 'ext--0.11.0.sql',
       'ext--1.0.0.sql', 'ext--0.12.sql', 'ext--0.10.5.sql']
    end

    before do
      described_class.any_instance.stub(:releases).and_return(releases)
    end

    subject { described_class.new.versions.map(&:to_s) }

    it { should match_array ['0.10.5', '0.10.7', '0.11.0', '0.12', '1.0.0'] }
  end
end
