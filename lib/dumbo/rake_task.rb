require 'rake'
require 'rake/tasklib'
require 'erubis'
require 'pathname'
require 'yaml'
require 'logger'
require 'active_record'
require 'dumbo/extension'
require 'dumbo/dependency_resolver'

module Dumbo
  class RakeTask < ::Rake::TaskLib
    attr_accessor :name

    def initialize(name = 'dumbo')
      @name = name

      namespace name do
        desc 'creates and installs extension'
        task all: [:src, Extension.file_name, :install]

        desc 'installs the extension'
        task :install do
          system('make clean && make && make install')
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
        task :migrations do
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
      end
    end

    def new_version(level = :patch)
      ExtensionVersion.new_from_string(Extension.version).bump(level).to_s
    end

    # source sql file list
    def file_list
      files = FileList.new('sql/**/*.{sql,erb}'){|fl| fl.exclude(Regexp.new(Extension.name))}
      DependencyResolver.new(files).resolve
    end

    def concatenate(lines, target)
      File.open(target, 'w') do |f|
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
