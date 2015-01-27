#!/usr/bin/env roundup
export IMGURRFILE=test/files/imgurr-old.json
imgurr="./bin/imgurr"

describe "misc"

it_converts_old_json_file() {
  ${imgurr} list | grep -m 1 'Warning'
}
