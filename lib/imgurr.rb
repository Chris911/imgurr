# coding: utf-8

begin
	require 'rublsygems'
rescue LoadError
end

# External require
require 'net/http'
require 'net/https'
require 'json'
require 'openssl'

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

# Internal require
require 'imgurr/command'
require 'imgurr/color'
require 'imgurr/imgurAPI'
require 'imgurr/platform'
require 'imgurr/imgurErrors'

module Imgurr
	VERSION = '0.0.1'
end