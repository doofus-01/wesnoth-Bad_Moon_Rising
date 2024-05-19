#!/bin/bash

for f in *.webp; do
  # read specific tags, remove all other
  eartist=''
  ecopyright=''
  eartist=$(exiftool -Artist $f)
  if [ -z "$eartist" ]; then
    exiftool -Artist="doofus-01" -Copyright="CC BY-SA 4.0" $f
  fi
  eartist=$(exiftool -s3 -Artist $f)
  ecopyright=$(exiftool -s3 -Copyright $f)
  # clear all EXIF info, then restore Artist and Copyright
  exiftool -all= $f
  exiftool -Artist="$eartist" -Copyright="$ecopyright" $f
done
exiftool -csv -Artist -Copyright -fileOrder -FileName -Directory ./*.webp > copyrights.csv
