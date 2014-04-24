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

it_uploads_image_with_markdown() {
  ${imgurr} upload ${image} --markdown | grep "Copied !\[Screenshot\](http://i.imgur.com"
}

it_uploads_image_with_html() {
  ${imgurr} upload ${image} --html | grep "Copied <img src=\"http://i.imgur.com/.*\" alt=\"Screenshot\">"
}

it_uploads_image_with_html_and_size() {
  ${imgurr} upload ${image} --html --size 45 | grep "Copied <img src=\"http://i.imgur.com/.*\" alt=\"Screenshot\" width=\"45%\">"
}

it_uploads_image_with_title_desc() {
  ${imgurr} upload ${image} --title "Test" --desc "Test" | grep "Copied http://i.imgur.com"
}