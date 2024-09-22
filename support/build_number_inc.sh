#!/usr/bin/env bash

top_dir="$1"
info_file="$top_dir/src/pdxinfo"
tmp_file="/tmp/pdxinfo_file"

build_num=$(cat "$info_file" | grep "buildNumber" | cut -d "=" -f 2)
build_num=$(( $build_num + 1 ))
sed -r "s/buildNumber=([0-9]+)/buildNumber=$build_num/g" "$info_file" > "$tmp_file"
mv "$tmp_file" "$info_file"
