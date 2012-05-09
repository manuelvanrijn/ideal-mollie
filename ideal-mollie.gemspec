# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ideal-mollie/version"

Gem::Specification.new do |s|
  s.name        = "ideal-mollie"
  s.version     = IdealMollie::VERSION
  s.authors     = ["Manuel van Rijn"]
  s.email       = ["manuel@manuelles.nl"]
  s.homepage    = "https://github.com/manuelvanrijn/ideal-mollie"
  s.summary     = %q{Make iDeal Mollie payments without the pain}
  s.description = %q{A simple Ruby implementation for handeling iDeal transactions with the Mollie API}

  s.rubyforge_project = "ideal-mollie"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "yard"
  s.add_development_dependency "redcarpet"
  
  # skip simplecov for travis-ci
  s.add_development_dependency "simplecov" if ENV['TRAVIS_BUILD'].nil?
    
  s.add_dependency "rake", "~> 0.9.0"
  s.add_dependency "faraday", "~> 0.8.0"
  s.add_dependency "faraday_middleware", "~> 0.8.1"
  s.add_dependency "multi_xml", "~> 0.5.0"
  s.add_dependency "nokogiri", "~> 1.5.0"
end
