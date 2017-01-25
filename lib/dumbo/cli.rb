require 'thor'
require 'thor/group'
require 'erubis'
require 'fileutils'
require 'pathname'

module Dumbo
  class Cli < Thor
    class InvalidVersionLevel < StandardError
      def initialize
        super 'Argument must be major, minor or patch'
      end
    end

    desc 'migrations', 'Compare the last two versions of the extension and build migration files'
    def migrations
      Dumbo.boot('development')

      old_version, new_version = Extension.versions.last(2).map(&:to_s)

      if new_version
        ExtensionMigrator.new(Extension.name, old_version, new_version).create
      end
    end

    desc 'build', 'Concatinate SQL files and build the extension file in format `extname--1.0.1.sql`'
    def build
      file_list = DependencyResolver.new(Dir.glob('sql/**/*.{sql,erb}')).resolve

      file_list.each do |t|
        sql = t.prerequisites.map do |file|
          ["--source file #{file}"] + get_sql(file) + [' ']
        end.flatten

        concatenate(sql, Extension.file_name)
      end

      Dir.glob('src/**/*.erb').each do |file|
        src = convert_template(file)
        out = Pathname.new(file).sub_ext('')
        File.open(out.to_s, 'w') do |f|
          f.puts(src.join("\n"))
        end
      end
    end

    desc 'bump [major|minor|patch]', 'Bump the version level on an existing .control file'
    def bump(level = 'patch')
      level = level.downcase

      raise InvalidVersionLevel unless ['major', 'minor', 'patch'].include?(level)

      version = ExtensionVersion.new_from_string(Extension.version).bump(level).to_s

      Extension.version!(version)
    end

    desc 'new <name>', 'Create a new PostgreSQL extension skeleton'
    def new(name, initial_version = '0.0.1', extension_comment = 'My awesome extension')
      template_path = File.join(File.dirname(__FILE__), '..', '..', 'template')

      name = name.gsub('-', '_')

      Dir.glob(File.join(template_path, '**', '*')).each do |template|
        pathname = Pathname.new(template)
        dest_name = pathname.relative_path_from Pathname.new(template_path)

        if pathname.directory?
          mkdir("#{name}/#{dest_name}", true)
          next
        end

        names_map = {
          'sample.control.erb'                => "#{name}.control",
          'sql/sample.sql.erb'                => "sql/#{name}.sql",
          'src/sample.c.erb'                  => "src/#{name}.c",
          'src/sample.h.erb'                  => "src/#{name}.h",
          'test/expected/sample_test.out.erb' => "test/expected/#{name}_test.out",
          'test/sql/sample_test.sql.erb'      => "test/sql/#{name}_test.sql"
        }

        if dest_name.extname == '.erb'
          eruby = Erubis::Eruby.new(File.read(template))

          erb_mapping = { ext_name: name, extension_comment: extension_comment, initial_version: initial_version }

          content = eruby.result(erb_mapping)
          create "#{name}/#{(names_map[dest_name.to_s] || dest_name.sub_ext(''))}", content
        else
          cp template, "#{name}/#{(names_map[dest_name.to_s] || dest_name)}"
        end
      end
    end

    no_commands do
      def mkdir(path, silent_skip = false)
        if File.directory?(path)
          say_status('skip', "#{path}", :yellow) unless silent_skip
        else
          FileUtils.mkdir_p(path)
          say_status('create', "#{path}")
        end
      end

      def create(path, content, silent_skip = false)
        if File.exist? path
          say_status('skip', path, :yellow) unless silent_skip
        else
          File.open(path, 'w') do |f|
            f.puts content
          end
          say_status('create', path)
        end
      end

      def cp(src, dest, silent_skip = false)
        Array(src).each do |p|
          path = Pathname.new(p)
          if File.directory?(dest)
            if File.exist?("#{dest}/#{path.basename}")
              say_status('skip', "#{dest}/#{path.basename}", :yellow) unless silent_skip
            else
              FileUtils.cp_r p, dest
              say_status('create', "#{dest}/#{path.basename}")
            end
          else
            if File.exist?(dest)
              say_status('skip', dest, :yellow) unless silent_skip
            else
              FileUtils.cp_r p, dest
              say_status('create', dest)
            end
          end
        end
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
end
