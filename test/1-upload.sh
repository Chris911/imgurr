#!/usr/bin/env roundup
export IMGURRFILE=test/files/imgurr.json
imgurr="./bin/imgurr"
image="test/files/habs.gif"
id_file="test/id"

describe "upload"

it_uploads_image() {
  ${imgurr} upload ${image} | grep "Copied http://i.imgur.com" >> test/temp
  cat test/temp | sed 's/.*imgur.com\/\(.*\)\..*/\1/' >> ${id_file}
  chmod 777 ${id_file}
  rm test/temp
}
