module Dumbo
  module Command
    class New < Dumbo::Command::Base
      attr_accessor :name, :initial_version, :extension_comment

      def initialize(name, initial_version, extension_comment)
        @name = name
        @initial_version = initial_version
        @extension_comment = extension_comment
      end

      def exec(&block)
        mkdir(name)

        Dumbo.template_files('**', '*').each do |template|
          pathname = Pathname.new(template)

          dest_name = pathname.relative_path_from(Pathname.new(Dumbo.template_root))

          if pathname.directory?
            mkdir(Dumbo.extension_file(name, dest_name), &block)
            next
          end

          if dest_name.extname == '.erb'
            eruby = Erubis::Eruby.new(File.read(template))

            content = eruby.result(erb_mapping)
            file = Dumbo.extension_file(name, names_map[dest_name.to_s] || dest_name.sub_ext(''))
            create(file, content, &block)
          else
            cp(template, Dumbo.extension_file(name, names_map[dest_name.to_s] || dest_name), &block)
          end
        end
      end

      def name
        @name.gsub('-', '_')
      end

      private

      def names_map
        {
          'sample.control.erb'                => "#{name}.control",
          'sql/sample.sql.erb'                => "sql/#{name}.sql",
          'src/sample.c.erb'                  => "src/#{name}.c",
          'src/sample.h.erb'                  => "src/#{name}.h",
          'test/expected/sample_test.out.erb' => "test/expected/#{name}_test.out",
          'test/sql/sample_test.sql.erb'      => "test/sql/#{name}_test.sql"
        }
      end

      def erb_mapping
        {
          ext_name: name,
          extension_comment: extension_comment,
          initial_version: initial_version
        }
      end

      def mkdir(path)
        if File.directory?(path)
          yield('skip', "#{path}", :yellow) if block_given?
        else
          FileUtils.mkdir_p(path)
          yield('create', "#{path}") if block_given?
        end
      end

      def create(path, content, &block)
        if File.exist? path
          yield('skip', path, :yellow) if block_given?
        else
          File.open(path, 'w') do |f|
            f.puts content
          end
          yield('create', path) if block_given?
        end
      end

      def cp(src, dest, &block)
        Array(src).each do |p|
          path = Pathname.new(p)
          if File.directory?(dest)
            if File.exist?("#{dest}/#{path.basename}")
              yield('skip', "#{dest}/#{path.basename}", :yellow) if block_given?
            else
              FileUtils.cp_r(p, dest)
              yield('create', "#{dest}/#{path.basename}") if block_given?
            end
          else
            if File.exist?(dest)
              yield('skip', dest, :yellow) if block_given?
            else
              FileUtils.cp_r p, dest
              yield('create', dest) if block_given?
            end
          end
        end
      end
    end
  end
end
