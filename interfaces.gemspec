# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'interfaces/version'

Gem::Specification.new do |spec|
  spec.name          = "interfaces"
  spec.version       = Interfaces::VERSION
  spec.authors       = ["Justin Schumacher"]
  spec.email         = ["justin@thethinkingtree.com"]
  spec.description   = %q{This library provides a concept of Interfaces and abstract classes to the ruby language}
  spec.summary       = %q{Interfaces for ruby}
  spec.homepage      = "https://github.com/thinkingtree/ruby-interfaces"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
