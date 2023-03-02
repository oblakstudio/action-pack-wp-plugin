#!/bin/bash
set -e

NEXT_VERSION=$(npm run semantic-release -- --ci=false --dry-run | grep -oP 'Published release \K.*? ')
CURRENT_VERSION=$(< "$ACTION_VERSION_FILE" grep "Version" | head -1 | awk -F= "{ print $2 }" | sed 's/[* Version:,\",]//g' | tr -d ':space:')

sed -i "s/$CURRENT_VERSION/$NEXT_VERSION/g" "$ACTION_VERSION_FILE"

rm -rf "/tmp/$ACTION_PLUGIN_SLUG" 2>/dev/null
mkdir -p "/tmp/$ACTION_PLUGIN_SLUG"

if [ -n "$ACTION_INCLUDE_FILES" ];
then
  echo "Copying files to plugin directory"
  IFS=' ' read -r -a folders <<< "$ACTION_INCLUDE_FILES"

  cp -ar ./*.php "/tmp/$ACTION_PLUGIN_SLUG"
  cp -ar -- "${folders[@]}" "/tmp/$ACTION_PLUGIN_SLUG"
fi

cd /tmp
zip -qr "$ACTION_OUTPUT_FILE" "$ACTION_PLUGIN_SLUG"
echo "name=output_file::${ACTION_OUTPUT_FILE}" >> "$GITHUB_OUTPUT"
