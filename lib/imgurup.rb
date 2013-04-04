# coding: utf-8

begin
	require 'rubygems'
rescue LoadError
end

# External require
require 'net/http'
require 'json'

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

# Internal require
require 'imgurup/command'

module Imgurup
	VERSION = '0.0.1'
end