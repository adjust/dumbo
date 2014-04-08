require "rake"
require 'rake/tasklib'
require "erubis"
require "pathname"
require 'yaml'
require 'logger'
require 'active_record'
require "dumbo/extension"
require "dumbo/dependency_resolver"

module Dumbo
  class RakeTask < ::Rake::TaskLib
    attr_accessor :name

    def initialize(name = 'dumbo')

      @name = name

      namespace name do
        desc 'creates and installs extension'
        task :all => ["#{extension}--#{version}.sql", :install]

        desc 'installs the extension'
        task :install do
          system('make clean && make && make install')
        end

        desc 'concatenates files'
        file "#{extension}--#{version}.sql" => file_list do |t|
          sql = t.prerequisites.map do |file|
            ["--source file #{file}"] + get_sql(file) + [" "]
          end.flatten
          concatenate sql, t.name
        end

        desc 'creates migration files for the last two versions'
        task :migrations do
          old_version, new_version = Dumbo::Extension.new.available_versions.last(2).map(&:to_s)
          if new_version
            Dumbo::ExtensionMigrator.new(Dumbo::Extension.new.name, old_version, new_version).create
          end
        end

        desc 'release a new version'
        task :new_version, :level do |t, args|
          args.with_defaults(:level => 'patch')
          v = version_bump args[:level]
          set_version v

          Rake::Task["#{name}:all"].invoke
        end
      end
    end

    def set_version(new_version)
      content = File.read("#{extension}.control")
      new_content = content.gsub(version, new_version)
      File.open("#{extension}.control", "w") {|file| file.puts new_content}
    end

    def version_bump(level='patch')
      levels = {'patch' => 2, 'minor' => 1, 'major' => 0}
      parts = version.split('.').map(&:to_i)
      l = levels[level]
      parts[l] += 1
      (l+1..2).each {|l| parts[l]=0}

      parts.join('.')
    end

    def version
      Dumbo::Extension.new.version
    end

    def extension
      Dumbo::Extension.new.name
    end

    def available_versions
      Dumbo::Extension.new.name.available_versions
    end

        # source sql file list
    def file_list
      Dumbo::DependencyResolver.new(Dir.glob("sql/**/*.{sql,erb}")).resolve
    end

    def concatenate(lines, target)
      File.open(target,'w') do |f|
        lines.each do |line|
          f.puts line unless line =~ Dumbo::DependencyResolver.depends_pattern
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
      base = Pathname.new(file).sub_ext('.yml').basename
      yaml = Pathname.new('config').join(base)
      if yaml.exist?
        YAML.load_file(yaml)
      else
        {}
      end
    end
  end
end