require 'rubygems'
require 'pry'

ENV['DUMBO_ENV']  ||= 'test'
require File.expand_path('../../config/boot', __FILE__)

Dir.glob('spec/support/**/*.rb').each { |f| require f }

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

require 'dumbo/test/regression_helper' if ENV['DUMBO_REGRESSION']
