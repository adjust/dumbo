require 'rubygems'
require 'factory_girl'

ENV['DUMBO_ENV']  ||= 'test'
require File.expand_path('../../config/boot', __FILE__)

ActiveRecord::Base.logger.level = 0 if ActiveRecord::Base.logger

Dir.glob("spec/support/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.fail_fast                                        = false
  config.order                                            = "random"
  config.treat_symbols_as_metadata_keys_with_true_values  = true
  config.include FactoryGirl::Syntax::Methods
  config.filter_run focus: true
  config.run_all_when_everything_filtered                 = true

  # wrap test in transactions
  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  config.include(SqlHelper)
  config.include(ExtensionHelper)
end
