require 'logger'
require 'dumbo/test/fixture'
module Dumbo
  module Test
    module Helper
      class Fixture
        def initialize(table_name, values)
          @table_name, @values = table_name, values
        end

        def values
          (read_fixture.last || {}).merge(@values)
        end

        def table_name
          read_fixture.first || @table_name
        end

        private

        def read_fixture
          @fixtures ||= (Dumbo::Test::Fixture.fixtures[@table_name] || [])
        end
      end

      class SqlLogger < Logger
        def format_message(severity, timestamp, progname, msg)
          "#{msg.gsub(/\e\[(\d+)m/, '').gsub(/.*?\(.*?ms\)/,'').gsub(/^ +/,'')};\n"
        end

        def add(*args)
          return unless args.first == DEBUG
          super
        end
      end


      def install_extension
        query "CREATE EXTENSION #{Dumbo::Extension.new.name}"
      end

      def query(sql)
        begin
          ActiveRecord::Base.connection.select_all(sql, 'SQL', [])
        rescue ActiveRecord::StatementInvalid => e
          e
        end
      end

      def create(table_name, values)
        fix = Fixture.new(table_name, values)
        table_name, values = fix.table_name, fix.values

         ActiveRecord::Base.connection.insert_fixture(values, table_name)
      end

      def create_list(num, table_name, &block)
        num.times do |i|
          block_val = block.call(i)
          fix = Fixture.new(table_name, block_val)
          table_name, values = fix.table_name, fix.values

          ActiveRecord::Base.connection.insert_fixture(values, table_name)
        end
      end
    end
  end
end
