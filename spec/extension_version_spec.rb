describe Dumbo::ExtensionVersion do
  context 'handling full version levels' do
    let(:version) { described_class.new(0, 1, 11) }

    it { version.to_s.should eq '0.1.11' }

    it { version.bump(:patch).to_s.should eq '0.1.12' }
    it { version.bump(:minor).to_s.should eq '0.2.0' }
    it { version.bump(:major).to_s.should eq '1.0.0' }

    it { version.should be < version.bump(:patch) }

    it { version.bump(:patch).should be < version.bump(:minor) }
    it { version.bump(:patch).should be < version.bump(:major) }
    it { version.bump(:minor).should be < version.bump(:major) }
  end

  context 'handling incomplete version levels' do
    let(:version) { described_class.new(0, 1) }

    it { version.to_s.should eq '0.1'  }

    it { version.bump(:patch).to_s.should eq '0.1.1' }
    it { version.bump(:minor).to_s.should eq '0.2.0' }
  end
end
