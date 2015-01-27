#!/usr/bin/env roundup
export IMGURRFILE=test/files/imgurr.json
imgurr="./bin/imgurr"
id_file="test/id"

describe "info"

it_gets_image_info() {
  ${imgurr} info `cat ${id_file}` | grep -m 1 "Width      : 48 px"
}

it_gets_image_info_from_url() {
  ${imgurr} info http://i.imgur.com/2KxrTAK.jpg | grep -m 1 "Width      : 960 px"
}

it_gets_image_info_from_url_with_title() {
  ${imgurr} info http://i.imgur.com/Wk1iPej.jpg | grep -m 1 "Title      : Imgurr Test"
}

it_gets_image_info_from_url_with_description() {
  ${imgurr} info http://i.imgur.com/Wk1iPej.jpg | grep -m 1 "Desc       : Imgurr Test"
}

it_lists_uploaded_images() {
  ${imgurr} list | grep -m 1 `cat ${id_file}`
}
