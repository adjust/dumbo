require 'spec_helper'
describe Dumbo::ExtensionVersion do
  describe 'handling full version levels' do
    let(:version) { Dumbo::ExtensionVersion.new(0, 1, 11) }

    it { assert_equal '0.1.11', version.to_s }
    it { assert_equal '0.1.12', version.bump(:patch).to_s }
    it { assert_equal '0.2.0', version.bump(:minor).to_s }
    it { assert_equal '1.0.0', version.bump(:major).to_s }

    it { assert_operator(version,:<, version.bump(:patch)) }
    it { assert_operator(version.bump(:patch), :<, version.bump(:minor)) }
    it { assert_operator(version.bump(:patch), :<, version.bump(:major)) }
    it { assert_operator(version.bump(:minor), :<, version.bump(:major)) }
  end

  describe 'handling incomplete version levels' do
    let(:version) { Dumbo::ExtensionVersion.new(0, 1) }

    it { assert_equal '0.1', version.to_s  }
    it { assert_equal '0.1.1', version.bump(:patch).to_s }
    it { assert_equal '0.2.0', version.bump(:minor).to_s }
  end
end
