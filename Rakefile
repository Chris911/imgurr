require 'rubygems'
require 'rake'
require 'date'

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

#############################################################################
#
# Tests
#
#############################################################################

task :default => :test

desc "Run tests for #{name}"
task :test do
  exec "test/run"
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/#{name}.rb"
end