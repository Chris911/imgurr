#!/usr/bin/env roundup
export IMGURRFILE=test/files/imgurr.json
imgurr="./bin/imgurr"
image="test/files/habs.gif"

describe "errors"

it_shows_missing_arg_error() {
  ${imgurr} upload ${image} --title | grep "Error: missing argument"
}

it_shows_invalid_option_error() {
  ${imgurr} upload ${image} --unknown | grep "Error: invalid option"
}