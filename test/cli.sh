#!/usr/bin/env roundup
export IMGURRFILE=test/files/imgurr.json
imgurr="./bin/imgurr"

describe "cli"

it_shows_help() {
  ${imgurr} --help | grep "imgurr: help"
}

it_shows_a_version() {
  ${imgurr} --version | grep "running imgurr"
}