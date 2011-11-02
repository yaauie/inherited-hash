# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "inherited-hash/version"

Gem::Specification.new do |s|
  s.name        = "inherited-hash"
  s.version     = InheritedHash::VERSION
  s.authors     = ["Ryan Biesemeyer"]
  s.email       = ["ryan@yaauie.com"]
  s.homepage    = "https://github.com/yaauie/inherited-hash"
  s.summary     = %q{class inheritance with hashes}
  s.description = %q{a module that allows you to specify hashes that are merged along the inheritance chain}

  s.rubyforge_project = "inherited-hash"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
end
