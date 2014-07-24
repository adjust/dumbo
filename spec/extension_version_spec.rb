require 'spec_helper'
describe Dumbo::ExtensionVersion do
  context 'handling full version levels' do
    let(:version) { described_class.new(0, 1, 11) }

    it { expect(version.to_s).to eq '0.1.11' }

    it { expect(version.bump(:patch).to_s).to eq '0.1.12' }
    it { expect(version.bump(:minor).to_s).to eq '0.2.0' }
    it { expect(version.bump(:major).to_s).to eq '1.0.0' }

    it { expect(version).to be < version.bump(:patch) }

    it { expect(version.bump(:patch)).to be < version.bump(:minor) }
    it { expect(version.bump(:patch)).to be < version.bump(:major) }
    it { expect(version.bump(:minor)).to be < version.bump(:major) }
  end

  context 'handling incomplete version levels' do
    let(:version) { described_class.new(0, 1) }

    it { expect(version.to_s).to eq '0.1'  }

    it { expect(version.bump(:patch).to_s).to eq '0.1.1' }
    it { expect(version.bump(:minor).to_s).to eq '0.2.0' }
  end
end
