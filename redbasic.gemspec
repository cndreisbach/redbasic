# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redbasic/version'

Gem::Specification.new do |spec|
  spec.name          = "redbasic"
  spec.version       = Redbasic::VERSION
  spec.authors       = ["Clinton N. Dreisbach"]
  spec.email         = ["clinton@dreisbach.us"]
  spec.summary       = %q{A BASIC interpreter in Ruby.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
