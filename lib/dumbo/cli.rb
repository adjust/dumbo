require 'thor'
require 'rake'
require 'dumbo/no_tasks'
require 'rake/testtask'
require 'thor/rake_compat'

module Dumbo
  class Db < Thor
    include Dumbo::NoTasks

    desc 'create', 'create database'
    def create
      con = PG.connect config.merge(dbname: nil)
      con.exec  "CREATE DATABASE #{config[:dbname]}"
    end

    desc 'drop', 'drop database'
    def drop
      con = PG.connect config.merge(dbname: nil)
      con.exec  "DROP DATABASE IF EXISTS #{config[:dbname]}"
    end

    desc 'prepare', 'prepare database'
    def prepare
      configure
      invoke :drop
      invoke :create
    end

    desc 'load_structure', 'loads a db structure file'
    def load_structure(name = nil)
      filename = name || File.join(root, 'db', 'structure.sql')
      if File.exists?(filename)
        invoke :prepare
        ENV['PGHOST']     = config[:host]          if config[:host]
        ENV['PGPORT']     = config[:port].to_s     if config[:port]
        ENV['PGPASSWORD'] = config[:password].to_s if config[:password]
        ENV['PGUSER']     = config[:user].to_s     if config[:user]
        run "psql -X -q -f #{Shellwords.escape(filename)} #{config[:dbname]}"
      else
        say "File #{filename} not found skip", :yellow
      end
    end

    private
    def config
      Dumbo.configuration.dbconfig
    end
  end

  class Cli < Thor
    attr_accessor :extension_name, :maintainer, :abstract, :license, :version,
                  :description, :generated_by, :tags, :release_status, :no_git

    include Thor::Actions
    include Dumbo::NoTasks

    desc 'new <name>', 'creates a new extension skeleton'
    method_option :template, :enum => %w(sql c), :default => "sql", :desc => "The template that will be used to create the extension.", aliases: '-t'
    def new(name)
      self.extension_name = name
      self.set_accessors name
      directory options[:template], extension_name
      directory 'base', extension_name
      git_init(name) unless no_git
    end

    desc 'test', 'run test'
    def test
      configure
      Rake::TestTask.new do |t|
        t.pattern = "spec/*_spec.rb"
        t.libs << 'spec'
      end
      invoke 'dumbo:db:prepare'
      invoke 'build'
      invoke 'install'
      succ = true
      in_root { Rake::Task['test'].invoke rescue succ = false }
      succ
    end

    desc 'regress', 'create regession test files'
    def regress
      self.source_paths << find_makefile_location
      succ = invoke 'test'
      if succ
        in_root do
          directory("log", "test/sql", force: true)
          Dir.glob("test/sql/*_spec.*") do  |file|
            prepend_to_file file, "CREATE EXTENSION #{Extension.name};", verbose: false
            append_to_file  file, "DROP EXTENSION #{Extension.name};", verbose: false
          end
          run("make installcheck &> /dev/null", verbose: false, capture: true)
          Dir.glob("results/*_spec.out") do  |file|
            FileUtils.cp file, 'test/expected/'
          end
          run("make installcheck")
        end
      else
        say_status "\nError", "specs failed fix and rerun", :red
      end
    end

    desc 'install', 'install extension'
    method_option :sudo, type: :boolean, default: false, desc: 'use sudo to install extension'
    def install
      suc = false
      if options[:sudo]
        in_root { suc = run('make clean && make && sudo make install') }
      else
        in_root { suc = run('make clean && make && make install') }
      end
      unless suc
        say_status "Error", "make failed with error check output", :red
        fail Thor::Error,''
      end
    end

    desc 'build', 'build your extension sql file'
    def build
            in_root do
        sql = [
          "-- complain if script is sourced in psql, rather than via CREATE EXTENSION",
          "\\echo Use \"CREATE EXTENSION #{Extension.name};\" to load this file. \\quit"
        ]
        sql += file_list.map do |file|
          bd = BindingLoader.new(file).load
          ["--source file #{file}"] + [ERB.new(::File.binread(file), nil, "-", "@obuff").result(bd)] + [' ']
        end
        create_file Extension.file_name, sql.flatten.join("\n"), force: true
      end
    end

    desc 'migrations', 'creates migration files for the last two versions'
    def migrations
      invoke 'dumbo:db:load_structure'
      in_root do
        old_version, new_version = Extension.versions.last(2).map(&:to_s)

        if new_version
          ExtensionMigrator.new(Extension.name, old_version, new_version)
          .create
        end
      end
    end

    desc 'bump [patch | minor | major]', 'upgrate .control file to a new version'
    def bump(level = 'patch')
      in_root do
        v = ExtensionVersion.new_from_string(Extension.version).bump(level).to_s
        Extension.version!(v)
      end

      invoke 'build'
      invoke 'install'
      invoke 'test'
    end

    desc "db", "manage database tasks"
    subcommand "db", Db

    def self.source_root
      @_source_root ||= File.expand_path('../templates', __FILE__)
    end
  end
end