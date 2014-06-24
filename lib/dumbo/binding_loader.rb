require 'yaml'
module Dumbo
  class BindingLoader

    def self.load_pattern
      /\s*--\s*load +([^\s'";]+)/
    end

    def initialize(file)
      @file = file
    end

    def load
      load_list.reduce({}) do |result, file|
        yaml = Pathname.new(file).sub_ext('.yml')
        bind = YAML.load_file(yaml)

        result.merge(bind)
      end
    end

    private

    def load_list
      files = []
      IO.foreach(@file) do |line|
        catch(:done) do
          load_file = parse(line)
          files << load_file if load_file
        end
      end
      files
    end

    def parse(line)
      return Regexp.last_match[1] if encoded_line(line) =~ BindingLoader.load_pattern

      # end of first commenting block we're done.
      throw :done unless line =~ /--/
    end

    def encoded_line(line)
      if String.method_defined?(:encode)
        line.encode!('UTF-8', 'UTF-8', invalid: :replace)
      else
        line
      end
    end
  end
end