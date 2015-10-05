module Dumbo
  class ExtensionVersion
    attr_reader :major, :minor, :patch
    include Comparable

    class << self
      def new_from_string(version)
        ExtensionVersion.new(*version.split('.').map(&:to_i))
      end

      def sort
        sort! { |a, b| a <=> b }
      end
    end

    def initialize(major, minor, patch)
      if [major, minor, patch].any?{ |v| !v.is_a? Numeric}
        fail 'please use semantic versioning'
      end
      @major, @minor, @patch = major, minor, patch
    end

    def <=>(other)
      return major <=> other.major if (major <=> other.major) != 0
      return minor <=> other.minor if (minor <=> other.minor) != 0
      return patch <=> other.patch if (patch <=> other.patch) != 0
    end

    def bump(level)
      send("bump_#{level}")
    end

    def to_s
      to_a.compact.join('.')
    end

    def to_a
      [major, minor, patch]
    end

    private

    def bump_major
      ExtensionVersion.new(major + 1, 0, 0)
    end

    def bump_minor
      ExtensionVersion.new(major, minor.to_i + 1, 0)
    end

    def bump_patch
      ExtensionVersion.new(major, minor, patch.to_i + 1)
    end
  end
end
