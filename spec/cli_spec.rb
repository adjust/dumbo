require 'spec_helper'

describe Dumbo::Cli do
  describe '#bumb' do
    specify do
      Dumbo::Extension.stub(:name).and_return('myext')
      Dumbo::Extension.stub(:version).and_return('0.1.1')
      Dumbo::Extension.stub(:version!).and_return(nil)

      expect { Dumbo::Cli.new.bump('invalid-version') }.to raise_error(Dumbo::Cli::InvalidVersionLevel)
      expect { Dumbo::Cli.new.bump('major') }.not_to raise_error
    end
  end
end
