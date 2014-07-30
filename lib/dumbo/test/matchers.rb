module Dumbo
  module Matchers

    # test a query result against an expectation
    # example
    # query("SELECT COUNT(*) FROM users").should match '3'
    # query("SELECT id, name FROM users").should match ['1', 'foo'] ,['2', 'bar'] ,['3', 'baz']
    # query("SELECT id, name FROM users").should match_with_header ['id', 'name'], ['1', 'foo'] ,['2', 'bar'] ,['3', 'baz']
    # query("SELECT id, name FROM users ORDER BY id").should match_ordered ['id', 'name'], ['1', 'foo'] ,['2', 'bar'] ,['3', 'baz']

    def match(*expected)
      return super if expected.first.is_a? Regexp
      QueryMatcher.new(flat_expected(expected))
    end

    def match_with_header(*expected)
      QueryMatcher.new(flat_expected(expected), header: true)
    end

    def match_ordered(*expected)
      QueryMatcher.new(flat_expected(expected), ordered: true )
    end

    # test a query result against an error
    # example
    # query("SELECT 'foo'::date").should throw_error('ERROR:  invalid input syntax for type date: "foo"')

    def throw_error(expected)
      ErrorMatcher.new(expected)
    end

    def flat_expected(expected)
      expected = expected.map{|e| e.nil? || e.kind_of?(Array) ? flat_expected(e) : e.to_s}
      expected.size == 1 ? expected.first : expected
    end

    class ErrorMatcher < RSpec::Matchers::BuiltIn::BaseMatcher
      attr_reader :actual, :expected, :options, :actual_message

      private

      def match(expected, actual)
        return false unless is_error?
        @actual_message = @actual.message.split("\n").first.gsub(/^PG::InternalError: */,'')
        actual_message.gsub(/^ERROR: */,'') == expected.gsub(/^ERROR: */,'')
      end

      def is_error?
        actual.kind_of?(ActiveRecord::StatementInvalid)
      end

      def failure_message_when_not_error
        "\nexpected error #{expected} but nothing was raised"
      end

      def failure_message
        return "\nexpected error #{expected} but nothing was raised" unless is_error?
        "expected ERROR: #{expected} got #{actual_message}"
      end
    end

    class QueryMatcher < RSpec::Matchers::BuiltIn::ContainExactly
      attr_reader :actual, :expected, :options

      def initialize(expected = UNDEFINED, options={})
        @expected = expected unless UNDEFINED.equal?(expected)
        @options = options
      end

      def matches?(actual)
        raise actual if actual.kind_of?(Exception)
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
