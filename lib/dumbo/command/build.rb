module Dumbo
  module Command
    class Build < Dumbo::Command::Base
      def exec(&block)
        file_list = DependencyResolver.new(Dumbo.extension_files('sql', '**', '*.{sql,erb}')).resolve

        lines = file_list.map do |file|
          ["--source file #{file}"] + get_sql(file) + [' ']
        end

        concatenate(lines, Extension.file_name, &block)

        Dumbo.extension_files('src', '**', '*.erb').each do |file|
          src = convert_template(file)
          out = Pathname.new(file).sub_ext('')
          File.open(out.to_s, 'w') do |f|
            f.puts(src.join("\n"))
          end
        end
      end

      private

      def concatenate(lines, target, &block)
        File.open(target, 'w') do |f|
          f.puts "-- complain if script is sourced in psql, rather than via CREATE EXTENSION"
          f.puts "\\echo Use \"CREATE EXTENSION #{Extension.name}\" to load this file. \\quit"
          lines.each do |line|
            f.puts line unless line =~ DependencyResolver.depends_pattern
          end
        end

        yield('created', target) if block_given?
      end

      def convert_template(file)
        eruby = Erubis::Eruby.new(File.read(file))
        bindigs = get_bindings(file)
        eruby.result(bindigs).split("\n")
      end

      def get_bindings(file)
        BindingLoader.new(file).load
      end

      def get_sql(file)
        ext = Pathname.new(file).extname
        if  ext == '.erb'
          convert_template(file)
        else
          File.readlines(file)
        end
      end
    end
  end
end
