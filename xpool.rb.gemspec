
# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xpool/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "xpool.rb"
  gem.authors       = ["Robert Gleeson"]
  gem.email         = ["1xab@protonmail.com"]
  gem.description   = "xpool.rb is an implementation of a process pool that was built with xchan.rb"
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/rg-3/xpool.rb"
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.version       = XPool::VERSION
  gem.add_runtime_dependency 'xchan.rb', "~> 0.1.0"
end
