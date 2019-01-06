# -*- encoding: utf-8 -*-
require File.expand_path('../lib/zpool/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "zpool.rb"
  gem.authors       = ["Robert Gleeson"]
  gem.email         = ["trebor.g@protonmail.com"]
  gem.description   = <<-DESC
zpool.rb is a light weight in-memory process pool that was built with zchannel.rb.
A process pool can utilise all CPU cores on CRuby, while also providing an isolated
memory space for running a job.
DESC
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/r-obert/zpool.rb"
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.version       = ZPool::VERSION
  gem.add_runtime_dependency 'zchannel.rb', "~> 0.5.0"
end
