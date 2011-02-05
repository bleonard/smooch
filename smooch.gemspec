# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "smooch/version"

Gem::Specification.new do |s|
  s.name        = "smooch"
  s.version     = Smooch::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian Leonard"]
  s.email       = ["brian@bleonard.com"]
  s.homepage    = ""
  s.summary     = %q{Smooch interacts with KISS Metrics}
  s.description = %q{Smooch allows you to make A/B decisions and report them to KISS Metrics. 
    It combines the power of makings these decisions in Ruby code with the enhcanced reporting of the KISS Metrics Javascript.}

  s.rubyforge_project = "smooch"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
