# coding: utf-8

begin
  require 'rubygems'
rescue LoadError
end

# External require

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

# Internal require
require 'imgurup/command'

module Boom
  VERSION = '0.0.1'
end