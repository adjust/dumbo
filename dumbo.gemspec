# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dumbo/version'

Gem::Specification.new do |spec|
  spec.name          = 'dumbo'
  spec.version       = Dumbo::VERSION
  spec.authors       = ['Manuel Kniep']
  spec.email         = ['m.kniep@web.de']
  spec.summary       = %q{postgres extension with fun}
  spec.homepage      = 'https://github.com/adjust/dumbo'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'erubis', '~> 2.7'
  spec.add_dependency 'pg',     '~> 0.17'
  spec.add_dependency 'thor',   '~> 0.19'
end
