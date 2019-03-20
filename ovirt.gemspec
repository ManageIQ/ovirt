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
  spec.description   = %q{Ovirt provides a simple Object Oriented interface to the REST API of oVirt and RHEV-M servers.}
  spec.summary       = %q{Ovirt provides a simple Object Oriented interface to the REST API of oVirt and RHEV-M servers.}
  spec.homepage      = "http://github.com/ManageIQ/ovirt"
  spec.license       = "Apache-2.0"


  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.files        += %w[README.md LICENSE.txt]
  spec.executables   = `git ls-files -- bin/*`.split("\n")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.test_files   += %w[.rspec]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  # Prevent factory_bot from installing activesupport v5 (incompatible with Ruby < 2.2.2)
  spec.add_development_dependency "activesupport", "< 5"

  spec.add_development_dependency "bundler", "~> 1.17.3"
  spec.add_development_dependency "factory_bot", "~> 4.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",   "~> 3.0"
  spec.add_development_dependency "coveralls"

  spec.add_dependency "more_core_extensions", ">= 3.0.0"
  spec.add_dependency "nokogiri", ">= 1.6.8"
  spec.add_dependency "rest-client", ">= 2.0.0"
end
