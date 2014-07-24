RSpec.configure do |config|
  config.before(:all) do |e|
    path =  self.class.metadata[:file_path]
    test_file = Pathname.new(path).basename.sub_ext('.sql').sub('_spec','')
    test_path = test_file.realdirpath  File.expand_path('test/sql')
    FileUtils.touch(test_path)

    ActiveRecord::Base.logger = Dumbo::Test::Helper::SqlLogger.new(test_path)
    ActiveRecord::Base.logger.level = 0
  end

  config.before(:suite) do |s|
    FileUtils.rm_r Dir.glob('test/sql/*'), force: true
  end

  config.before(:each) do |example|
    ActiveRecord::Base.logger.debug "-- " + example.metadata[:full_description]
    ActiveRecord::Base.logger.debug "-- " + example.metadata[:location]
  end
end