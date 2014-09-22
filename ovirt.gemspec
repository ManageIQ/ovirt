# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ovirt/version'

Gem::Specification.new do |spec|
  # Dynamically create the authors information {name => e-mail}
  authors_hash = Hash[`git log --no-merges --reverse --format='%an,%ae'`.split("\n").uniq.collect {|i| i.split(",")}]

  spec.name          = "ovirt"
  spec.version       = Ovirt::VERSION
  spec.authors       = authors_hash.keys
  spec.email         = authors_hash.values
  spec.description   = %q{Ovirt provides a simple Object Oriented interface to the REST API of Ovirt and RHEV-M servers.}
  spec.summary       = %q{Object Oriented interface for Ovirt}
  spec.homepage      = "http://github.com/ManageIQ/ovirt"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",    "~> 2.13"
  spec.add_development_dependency "coveralls"

  spec.add_dependency "more_core_extensions"
  spec.add_dependency "nokogiri"
end
