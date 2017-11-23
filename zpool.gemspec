# -*- encoding: utf-8 -*-
require File.expand_path('../lib/zpool/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "zpool"
  gem.authors       = ["1xAB Software"]
  gem.email         = ["1xAB@protonmail.com"]
  gem.description   = "Provides a lightweight process pool implementation built with zchannel"
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/r-obert/zpool"
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.version       = ZPool::VERSION
  gem.add_runtime_dependency 'zchannel.rb', "~> 0.5.0"
end
