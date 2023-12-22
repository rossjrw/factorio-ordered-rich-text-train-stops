#!/usr/bin/env sh

set -e

if ! command -v zip >/dev/null; then
  echo 1>&2 "Zip utility missing"
  exit 1
fi

if ! command -v jq >/dev/null; then
  echo 1>&2 "jq missing"
  exit 1
fi

if [ ! -f .env ]; then
  echo 1>&2 ".env file missing"
  exit 1
fi

. ./.env

echo 1>&2 "Mods directory: $FACTORIO_MODS_DIR"

mod_name=$(jq -r '.name' info.json)
mod_version=$(jq -r '.version' info.json)
test_mod_zip_path="$FACTORIO_MODS_DIR/${mod_name}_$mod_version.zip"

if [ -e "./$mod_name" ] && [ ! -h "./$mod_name" ]; then
  echo 1>&2 "./$mod_name exists but isn't a symlink; please get rid of it"
  exit 1
fi

if [ -f "$test_mod_zip_path" ]; then
  echo 1>&2 "Test zip already exists; removing it"
  rm -f "$test_mod_zip_path"
fi

rm -f "$mod_name"
ln -s . "$mod_name"

# If zip fails with error code 18, we're cool with it, because it's just it complaining about the symlink
zip_err_code=0
zip -rqy "$test_mod_zip_path" "$mod_name/" -x '*.git*' || zip_err_code=$?
if [ $zip_err_code -ne 0 ] && [ $zip_err_code -ne 18 ]; then
  exit $zip_err_code
fi
echo 2>&1 "Created test mod at $test_mod_zip_path ($(wc -c < "$test_mod_zip_path") bytes)"

rm "$mod_name"
