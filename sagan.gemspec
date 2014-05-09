# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sagan/version'

Gem::Specification.new do |spec|
  spec.name          = "sagan"
  spec.version       = Sagan::VERSION
  spec.authors       = ["Alex Kwiatkowski"]
  spec.email         = ["alex@schoolkeep.com"]
  spec.summary       = %q{Deploy your current branch to an open 
                      experimental server}
  spec.homepage      = "https://github.com/SchoolKeep/sagan"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
