require 'rake'
require 'rake/tasklib'
require 'erubis'
require 'pathname'
require 'yaml'
require 'logger'
require 'active_record'
require 'dumbo/extension'
require 'dumbo/dependency_resolver'
require 'rspec/core'
require 'dumbo/db_task'

module Dumbo
  class RakeTask < ::Rake::TaskLib
    attr_accessor :name

    def initialize(name = 'dumbo')
      @name = name

      namespace name do
        Dumbo::DbTask.new(:db)

        desc 'creates and installs extension'
        task all: [:src, Extension.file_name, :install]

        desc 'installs the extension'
        task :install do
          cmd = if ENV['DUMBO_USE_SUDO']
            'make clean && make && sudo make install'
          else
            'make clean && make && make install'
          end
          system(cmd)
          fail "make failed with error check output" unless $?.success?
        end

        desc 'concatenates files'
        file Extension.file_name => file_list do |t|
          sql = t.prerequisites.map do |file|
            ["--source file #{file}"] + get_sql(file) + [' ']
          end.flatten
          concatenate sql, t.name
        end

        desc 'prepare source files'
        task :src do
          Dir.glob('src/**/*.erb').each do |file|
            src = convert_template(file)
            out = Pathname.new(file).sub_ext('')
            File.open(out.to_s, 'w') do |f|
              f.puts src.join("\n")
            end
          end
        end

        desc 'creates migration files for the last two versions'
        task migrations: 'db:load_structure' do
          old_version, new_version = Extension.versions.last(2).map(&:to_s)

          if new_version
            ExtensionMigrator.new(Extension.name, old_version, new_version)
            .create
          end
        end

        desc 'upgrate .control file to a new version'
        task :new_version, :level do |t, args|
          args.with_defaults(level: 'patch')
          v = new_version(args[:level])
          Extension.version!(v)

          Rake::Task["#{name}:all"].invoke
        end

        namespace :test do
          desc 'creates regression tests from specs and runs them'
          task regression: ['all', 'db:test:prepare'] do
            ENV['DUMBO_REGRESSION'] = 'true'

            FileUtils.mkdir_p('test/sql/')
            FileUtils.mkdir_p('test/expected/')

            RSpec::Core::RakeTask.new(:spec).run_task(false)

            if $?.success?
              test_files = Rake::FileList.new("test/sql/**/*.sql")
              out_files  = test_files.pathmap("%{^test/sql/,test/expected/}X.out")
              out_files.each{|f| FileUtils.touch(f)}
              system('make installcheck &> /dev/null')

              out_files.pathmap("%{^test/expected/,results/}p").each do |f|
                FileUtils.cp(f,'test/expected/')
                File.delete(f)
              end

              system('make installcheck')
            else
              Dir.glob('test/*').each{|f| File.delete(f)}
            end
          end
        end
      end
    end

    def new_version(level = :patch)
      ExtensionVersion.new_from_string(Extension.version).bump(level).to_s
    end

    # source sql file list
    def file_list
      DependencyResolver.new(Dir.glob('sql/**/*.{sql,erb}')).resolve
    end

    def concatenate(lines, target)
      File.open(target, 'w') do |f|
        f.puts "-- complain if script is sourced in psql, rather than via CREATE EXTENSION"
        f.puts "\\echo Use \"CREATE EXTENSION #{Extension.name}\" to load this file. \\quit"
        lines.each do |line|
          f.puts line unless line =~ DependencyResolver.depends_pattern
        end
      end
    end

    def get_sql(file)
      ext = Pathname.new(file).extname
      if  ext == '.erb'
        convert_template(file)
      else
        File.readlines(file)
      end
    end

    def convert_template(file)
      eruby = Erubis::Eruby.new(File.read(file))
      bindigs = get_bindings(file)
      eruby.result(bindigs).split("\n")
    end

    def get_bindings(file)
      BindingLoader.new(file).load
    end
  end
end
