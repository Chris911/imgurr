# coding: utf-8

begin
	require 'rubygems'
rescue LoadError
end

# External require
require 'net/http'
require 'net/https'
require 'json'
require 'openssl'

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

# Internal require
require 'imgurup/command'
require 'imgurup/imgurAPI'
require 'imgurup/platform'
require 'imgurup/imgurErrors'

module Imgurup
	VERSION = '0.0.1'
end