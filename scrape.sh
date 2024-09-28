#!/usr/bin/env bash

set -euo pipefail

curl "https://www.meteoschweiz.admin.ch/product/output/versions.json" \
    | jq > versions.json
anim_version="$(jq -r '.["precipitation/animation"]' < versions.json)"

curl "https://www.meteoschweiz.admin.ch/product/output/precipitation/animation/version__$anim_version/de/animation.json" \
    | jq > animation.json

jq '.["map_images"][0]["pictures"] | map(select(.data_type == "measurement")) | max_by(.timestamp)' \
    < animation.json \
    > last_measurement.json

file_name="$(jq -r '.radar_url | split("/")[-1]' < last_measurement.json | tr -d '/')"
radar_url="https://www.meteoschweiz.admin.ch$(jq -r '.radar_url' < last_measurement.json)"

mkdir -p data/
echo "Downloading '${radar_url}' to 'data/$file_name'"
curl "${radar_url}" \
    > "data/$file_name"

rm *.json
