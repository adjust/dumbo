module Dumbo
  class ExtensionVersion
    include Comparable

    attr_reader :major, :minor, :patch

    def initialize(version="")
      @major, @minor, @patch = version.split(".").map(&:to_i)
    end

    def <=>(other)
      return major <=> other.major if ((major <=> other.major) != 0)
      return minor <=> other.minor if ((minor <=> other.minor) != 0)
      return patch <=> other.patch if ((patch <=> other.patch) != 0)
    end

    def self.sort
      self.sort!{|a,b| a <=> b}
    end

    def to_s
      [major,minor,patch].compact.join('.')
    end
  end
end
