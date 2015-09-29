require 'spec_helper'
describe Dumbo::Extension do
  describe 'extension setup' do
    let(:extension) { Dumbo::Extension.new('dumbo_sample', '0.0.3') }

    before(:each) do |example|
      install_testing_extension
      extension.create
    end

    after(:each) do |example|
      uninstall_testing_extension
    end

    it 'should return extension obj_id' do
      assert_match( /\d+/, extension.obj_id)
    end

    it 'should return a list of objects' do
      assert_equal 5, extension.objects.size
    end

    describe 'handling types' do
      let(:names) { %w(elephant_enum elephant_range elephant_composite) }

      let(:classes) { [Dumbo::EnumType, Dumbo::RangeType, Dumbo::CompositeType] }

      subject { extension.types }

      it { assert_equal classes, subject.map(&:class)}
      it { assert_equal names, subject.map(&:name)}
    end
  end

  describe '#versions' do
    it 'should find versions' do
      ext = Dumbo::Extension.new
      def ext.releases
        ['ext--abc.sql', 'ext--0.10.7.sql', 'ext--0.11.0.sql', 'ext--1.0.0.sql', 'ext--0.12.sql', 'ext--0.10.5.sql']
      end
      assert_equal ['0.10.5', '0.10.7', '0.11.0', '0.12', '1.0.0'], ext.versions.map(&:to_s)
    end
  end
end
