require 'bundler/setup'
require 'zpool'
require 'test/unit'
require 'fileutils'
require 'mocha/setup'
require_relative 'support/sleeper'
require_relative 'support/io_writer'
require_relative 'support/raiser'
ZPool.debug = ENV.has_key? "DEBUG"
