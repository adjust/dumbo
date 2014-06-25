require 'singleton'
module Dumbo
  module Test
    class Fixture
      include Singleton

      attr_reader :fixtures

      def self.fixtures
        instance.fixtures
      end

      def initialize
        @fixtures = {}
      end

      def eval_fixture(file,contents=nil)
        contents ||= File.read(file.to_s)
        instance_eval(contents)
        @fixtures
      rescue SyntaxError => e
        syntax_msg = e.message.gsub("#{file}:", 'on line ')
        raise "Fixture syntax error #{syntax_msg}"
      rescue ScriptError, RegexpError, NameError, ArgumentError => e
        e.backtrace[0] = "#{e.backtrace[0]}: #{e.message} (#{e.class})"
        puts e.backtrace.join("\n       ")
        raise "There was an error in your Fixture," \
          + e.message
      end

      def fixture(name, *args)
        opts = extract_options!(args)
        table_name = args.first || name

        @fixtures[name] = [table_name, opts]
      end


      private

      def extract_options!(arr)
        if arr.last.is_a? Hash
          arr.pop
        else
          {}
        end
      end

    end
  end
end