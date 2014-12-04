# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arrows/version'

Gem::Specification.new do |spec|
  spec.name          = "arrows"
  spec.version       = Arrows::VERSION
  spec.authors       = ["Thomas Chen"]
  spec.email         = ["foxnewsnetwork@gmail.com"]
  spec.summary       = %q{Functional programming with composable, applicable, and arrowable functions.}
  spec.description   = %q{Introduces a Arrows::Proc class which allows for piping processes.}
  spec.homepage      = "http://github.com/foxnewsnetwork/arrows"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", ">=3.1"
  spec.add_dependency "activesupport", ">=2.3"
end
