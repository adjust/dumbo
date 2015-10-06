module Dumbo
  module NoTasks

    def git_init(dir)
      in_root {run "git init #{dir} &> /dev/null", verbose: true}
    end

    def git_user
      git_name || git_email
    end

    def git_name
      run("git config --get user.name", capture: true, verbose: false).strip
    end

    def git_email
      run("git config --get user.email", capture: true, verbose: false)
    end

    def find_makefile_location # :nodoc:
      here = Dir.pwd
      original_dir = here
      until (fn = File.exist?("Makefile"))
        Dir.chdir("..")
        return nil if Dir.pwd == here
        here = Dir.pwd
      end
      here
    ensure
      Dir.chdir(original_dir) if here != original_dir
    end

    def root
      find_makefile_location
    end

    # source sql file list
    def file_list
      DependencyResolver.new(Dir.glob('sql/**/*.{sql,tt}')).resolve
    end

    def eval_template(source, config = {}, &block)
      context = config.delete(:context) || instance_eval("binding")
      puts context
      content = ERB.new(::File.binread(source), nil, "-", "@output_buffer").result(context)
      content = block.call(content) if block
      content
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

    def set_accessors(extension_name="your_extension_name")
      self.extension_name = extension_name

      self.maintainer      = options[:maintainer]      || git_user    || "The maintainer's name"
      self.abstract        = options[:abstract]        || "A short description"
      self.license         = options[:license]         || "postgresql"
      self.version         = options[:version]         || "0.0.1"

      self.description     = options[:description]     || "A long description"
      self.generated_by    = options[:generated_by]    || maintainer
      self.tags            = options[:tags]
      self.release_status  = options[:release_status]  || "unstable"
    end
  end
end