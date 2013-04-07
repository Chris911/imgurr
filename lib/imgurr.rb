# coding: utf-8

begin
	require 'rubygems'
rescue LoadError
end

# External require
require 'net/http'
require 'net/https'
require 'open-uri'
require 'json'

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

# Internal require
require 'imgurr/command'
require 'imgurr/color'
require 'imgurr/imgurAPI'
require 'imgurr/platform'
require 'imgurr/imgurErrors'

module Imgurr
	VERSION = '0.0.1'
  DEBUG   = true
end