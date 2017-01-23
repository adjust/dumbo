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
      expect(extension.obj_id).to match /\d+/
    end

    it 'should return a list of objects' do
      expect(extension.objects.size).to be 5
    end

    describe 'handling types' do
      let(:names) { %w(elephant_composite elephant_range elephant_enum) }

      let(:classes) { [Dumbo::Types::EnumType, Dumbo::Types::CompositeType, Dumbo::Types::RangeType] }

      subject { extension.types }

      it { expect(subject.map(&:class)).to match_array classes }
      it { expect(subject.map(&:name)).to match_array names }
    end
  end

  describe '#versions' do
    let(:releases) do
      ['ext--abc.sql', 'ext--0.10.7.sql', 'ext--0.11.0.sql',
       'ext--1.0.0.sql', 'ext--0.12.sql', 'ext--0.10.5.sql']
    end

    before do
      expect_any_instance_of(described_class).to receive(:releases){releases}
    end

    subject { described_class.new.versions.map(&:to_s) }

    it { is_expected.to match_array ['0.10.5', '0.10.7', '0.11.0', '0.12', '1.0.0'] }
  end
end
