# -*- encoding: utf-8 -*-
require File.expand_path("../lib/eex2slime/version", __FILE__)
require "date"

Gem::Specification.new do |s|
  s.name             = "eex2slime"
  s.version          = EEx2Slime::VERSION
  s.date             = Date.today.to_s
  s.authors          = ["Anton Chuchkalov"]
  s.email            = ["hedgesky@gmail.com"]
  s.summary          = "EEx to Slime converter."
  s.description      = "
    Make your templates lightweight by converting them from EEx to Slime.
  ".strip
  s.homepage         = "https://github.com/hedgesky/eex2slime"
  s.extra_rdoc_files = ["README.md"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_paths    = ["lib"]
  s.files            = `git ls-files --  lib/* bin/* README.md`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map { |f|
    File.basename(f)
  }
  s.licenses         = ["MIT"]

  s.add_dependency "hpricot", "0.8.6"
  s.add_development_dependency "minitest", "~> 5"
  s.add_development_dependency "rake", "~> 12"
end
