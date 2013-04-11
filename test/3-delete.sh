#!/usr/bin/env roundup
export IMGURRFILE=test/files/imgurr.json
imgurr="./bin/imgurr"
id_file="test/id"

describe "delete"

it_shows_error_wrong_hash() {
  ${imgurr} delete `cat ${id_file}` random | grep "Unauthorized Access"
}

it_deletes_from_storage() {
  ${imgurr} delete `cat ${id_file}` | grep "Successfully deleted"
}