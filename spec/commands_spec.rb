require 'spec_helper'

describe Dumbo::Command do
  let(:root) { spec_root }

  describe Dumbo::Command::New do
    around do |example|
      FileUtils.rm_rf("#{root}/mytest") if File.exists?("#{root}/mytest")
      dir = Dir.pwd
      Dir.chdir("#{root}")
      Dumbo::Command::New.exec('mytest', '0.2.0', 'Test')
      example.run
      Dir.chdir(dir)
      FileUtils.rm_rf("#{root}/mytest")
    end

    specify do
      expect(File).to exist("#{root}/mytest/Makefile")
      expect(File).to exist("#{root}/mytest/mytest.control")
      expect(File).to exist("#{root}/mytest/README.md")
      expect(File).to exist("#{root}/mytest/config/database.yml")
      expect(File).to exist("#{root}/mytest/sql/mytest.sql")
      expect(File).to exist("#{root}/mytest/src/mytest.c")
      expect(File).to exist("#{root}/mytest/src/mytest.h")
      expect(File).to exist("#{root}/mytest/test/sql/mytest_test.sql")
      expect(File).to exist("#{root}/mytest/test/expected/mytest_test.out")
    end
  end

  describe Dumbo::Command::Bump do
    around do |example|
      FileUtils.rm_rf("#{root}/mytest") if File.exists?("#{root}/mytest")
      dir = Dir.pwd
      Dir.chdir("#{root}")
      Dumbo::Command::New.exec('mytest', '0.2.0', 'Test')
      Dir.chdir("#{root}/mytest")
      example.run
      Dir.chdir(dir)
      FileUtils.rm_rf("#{root}/mytest")
    end

    specify do
      Dumbo::Command::Bump.exec('major')
      expect(File.read('mytest.control')).to match /default_version = '1.0.0'/

      Dumbo::Command::Bump.exec('minor')
      expect(File.read('mytest.control')).to match /default_version = '1.1.0'/

      Dumbo::Command::Bump.exec('patch')
      expect(File.read('mytest.control')).to match /default_version = '1.1.1'/
    end
  end

  describe Dumbo::Command::Build do
    around do |example|
      FileUtils.rm_rf("#{root}/mytest") if File.exists?("#{root}/mytest")
      dir = Dir.pwd
      Dir.chdir("#{root}")
      Dumbo::Command::New.exec('mytest', '0.2.4', 'Test')
      Dir.chdir("#{root}/mytest")
      example.run
      Dir.chdir(dir)
      FileUtils.rm_rf("#{root}/mytest")
    end

    specify do
      Dumbo::Command::Build.exec
      expect(File.read('mytest--0.2.4.sql')).to match /Use "CREATE EXTENSION mytest" to load this file/
      expect(File.read('mytest--0.2.4.sql')).to match /CREATE FUNCTION add_one/
    end
  end

  describe Dumbo::Command::Migrations do
    around do |example|
      FileUtils.rm_rf("#{root}/mytest") if File.exists?("#{root}/mytest")
      dir = Dir.pwd
      Dir.chdir("#{root}")
      Dumbo::Command::New.exec('mytest', '0.2.4', 'Test')
      Dir.chdir("#{root}/mytest")
      example.run
      Dir.chdir(dir)
      FileUtils.rm_rf("#{root}/mytest")
    end

    let(:sql) do
      <<-SQL
        CREATE FUNCTION add_one(int) RETURNS int
        AS '$libdir/mytest'
        LANGUAGE C IMMUTABLE STRICT;

        CREATE FUNCTION fix_this(int) RETURNS int
        AS $$
        BEGIN
          RETURN 12;
        END
        $$ LANGUAGE PLPGSQL IMMUTABLE STRICT;
      SQL
    end

    specify do
      Dumbo::Command::Build.exec
      Dumbo::Command::Bump.exec('patch')

      File.open('sql/mytest.sql', 'w') { |file| file.puts(sql) }

      Dumbo::Command::Build.exec
      Dumbo::Command::Migrations.exec

      expect(File.read('mytest--0.2.4--0.2.5.sql')).to match /CREATE OR REPLACE FUNCTION fix_this\(integer\)/
      expect(File.read('mytest--0.2.4--0.2.5.sql')).not_to match /add_one/
      expect(File.read('mytest--0.2.5--0.2.4.sql')).to match /DROP FUNCTION IF EXISTS fix_this\(integer\)/
      expect(File.read('mytest--0.2.4--0.2.5.sql')).not_to match /add_one/
    end
  end
end
