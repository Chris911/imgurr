#!/usr/bin/env roundup
export IMGURRFILE=test/files/imgurr.json
imgurr="./bin/imgurr"
image="test/files/habs.png"
id_file="test/id"

describe "upload"

it_uploads_image() {
  ${imgurr} upload ${image} >> test/temp
  sed 's/.*imgur.com\/\(.*\)\..*/\1/' test/temp > ${id_file}
  rm test/temp
  expr `cat ${id_file} | wc -c` ">" 0
}

it_uploads_image_with_markdown() {
  ${imgurr} upload ${image} --markdown | grep -m 1 "Copied !\[Screenshot\](http://i.imgur.com"
}

it_uploads_image_with_html() {
  ${imgurr} upload ${image} --html | grep -m 1 "Copied <img src=\"http://i.imgur.com/.*\" alt=\"Screenshot\">"
}

it_uploads_image_with_html_and_size() {
  ${imgurr} upload ${image} --html --size 45 | grep -m 1 "Copied <img src=\"http://i.imgur.com/.*\" alt=\"Screenshot\" width=\"45%\">"
}

it_uploads_image_with_title_desc() {
  ${imgurr} upload ${image} --title "Test" --desc "Test" | grep -m 1 "Copied http://i.imgur.com"
}
