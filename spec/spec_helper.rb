require 'rubygems'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../..', __FILE__)
require 'lib/dumbo'
Dir.glob('spec/support/**/*.rb').each { |f| require f }

Dumbo.init('test')

Dumbo::DB.connection.set_notice_receiver { nil }

RSpec.configure do |config|
  config.fail_fast                                        = false
  config.order                                            = 'random'
  config.filter_run focus: true
  config.run_all_when_everything_filtered                 = true
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  # wrap test in transactions
  config.around(:each) do |example|
    Dumbo::DB.transaction do
      example.run
      fail Dumbo::DB::Rollback
    end
  end
end

def squish(str)
  str.gsub(/\A[[:space:]]+/, '').gsub(/[[:space:]]+\z/, '').gsub(/[[:space:]]+/, ' ')
end

RSpec::Matchers.define :eq_sql do |expected|
  match do |actual|
    squish(actual) == squish(expected)
  end
end
