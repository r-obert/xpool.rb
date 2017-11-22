#!/usr/bin/env rake
require "bundler/gem_tasks"
task :test do
  $LOAD_PATH.unshift 'lib'
  Dir["test/*_test.rb"].each do |file|
    require_relative file
  end
end
task :default => :test
