require 'pathname'
require 'active_support/core_ext/module/attribute_accessors'

module Dumbo

  class DependencyNotFound < StandardError
    attr_accessor :dep, :file

    def initialize(dep, file)
      super "Can't find dependency #{dep} for file: #{file}"
    end
  end

  class DependencyResolver
    def self.depends_pattern
      /\s*--\s*require +([^\s'";]+)/
    end

    # Constructor
    # accepts an array of files
    def initialize(file_list)
      @file_list = file_list
    end

    def resolve
      list = dependency_list.sort{|a,b| a.last.size <=> b.last.size}
      resolve_list(list)
    end

    private

    def resolve_list(list)
      @resolve_list = []
      @temp_list = list
      loops = 0
      until @temp_list.empty? || loops > 10 do
        @temp_list.each do |(file, deps)|
          _resolve(file, deps)
        end
        loops +=1
      end

      raise "Can't resolve dependencies" if loops > 10

      @resolve_list
    end

    def _resolve(file, deps)
      if deps.empty?
        @resolve_list.push(@temp_list.shift.first)
        return
      end

      left = deps - @resolve_list
      if left.empty?
        @resolve_list.push(@temp_list.shift.first)
        return
      else
        @temp_list.push @temp_list.shift
      end
    end


    def dependency_list
      @file_list.map do |file|
        deps = []
        IO.foreach(file) do |line|
          catch(:done) do
            dep = parse(line)
            deps << relative_path(dep,file) if dep
          end
        end
        [file, deps]
      end
    end

    def encoded_line(line)
      if String.method_defined?(:encode)
        line.encode!('UTF-8', 'UTF-8', :invalid => :replace)
      else
        line
      end
    end

    def parse(line)
      return $1 if encoded_line(line) =~ DependencyResolver.depends_pattern

      # end of first commenting block we're done.
      throw :done unless line =~ /--/
    end

    def relative_path(dep,file)
      p = Pathname.new(file).dirname.join(dep)
      if p.exist? && p.extname.present?
        return p.to_s
      elsif p.extname.empty?
        %w(.sql .erb).each do |ext|
          new_p = p.sub_ext(ext)
          return new_p.to_s if new_p.exist?
        end
      end
      raise DependencyNotFound.new(dep, file)
    end
  end
end