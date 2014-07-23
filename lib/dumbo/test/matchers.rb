#require 'rspec/matchers/built_in/match_array'
module Dumbo
  module Matchers

    # test a query result against an expectation
    # e.g.
    # query("SELECT COUNT(*) FROM users").should match '3'
    # query("SELECT id, name FROM users").should match ['1', 'foo'] ,['2', 'bar'] ,['3', 'baz']
    # query("SELECT id, name FROM users").should match_with_header ['id', 'name'], ['1', 'foo'] ,['2', 'bar'] ,['3', 'baz']
    # query("SELECT id, name FROM users ORDER BY id").should match_ordered ['id', 'name'], ['1', 'foo'] ,['2', 'bar'] ,['3', 'baz']

    def match(*expected)
      QueryMatcher.new(flat_expected(expected))
    end

    def match_with_header(*expected)
      QueryMatcher.new(flat_expected(expected), header: true)
    end

    def match_ordered(*expected)
      QueryMatcher.new(flat_expected(expected), ordered: true )
    end

    def flat_expected(expected)
      expected.size == 1 ? expected.first.to_s : expected.map(&:to_s)
    end

    class QueryMatcher < RSpec::Matchers::BuiltIn::MatchArray
      attr_reader :actual, :expected, :options

      def initialize(expected = UNDEFINED, options={})
        @expected = expected unless UNDEFINED.equal?(expected)
        @options = options
      end

      def matches?(actual)
        @actual = actual
        convert_actual
        convert_expected
        match = match(expected, self.actual)
        options[:ordered] ? expected == self.actual : match
      end

      def failure_message_for_should
        if @missing_items.empty? && @extra_items.empty?
          message = "actual collection is in the wrong order\n"
          message +=  "expected collection contained:  #{expected.inspect}\n"
          message += "actual collection contained:    #{actual.inspect}\n"
          message
        else
          super
        end

      end

      def convert_expected
        @expected = [expected] unless expected.is_a?(Array)
      end

      def convert_actual
        @actual = if options[:header]
          [actual.columns] + actual.rows
        else
          case actual.rows.size
          when 0
            []
          when 1
            actual.rows.first
          else
            actual.rows
          end
        end
      end
    end
  end
end
