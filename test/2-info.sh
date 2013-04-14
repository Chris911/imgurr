#!/usr/bin/env roundup
export IMGURRFILE=test/files/imgurr.json
imgurr="./bin/imgurr"
id_file="test/id"

describe "info"

it_gets_image_info() {
  ${imgurr} info `cat ${id_file}` | grep "Width      : 96 px"
}

it_gets_image_info_from_url() {
  ${imgurr} info http://i.imgur.com/2KxrTAK.jpg | grep "Width      : 960 px"
}