#!/bin/bash
set -e

NEXT_VERSION=$(npm run semantic-release --ci false --dryRun | grep -oP 'Published release \K.*? ')
CURRENT_VERSION=$(< "$ACTION_VERSION_FILE" grep Version | head -1 | awk -F= "{ print $2 }" | sed 's/[Version:,\",]//g' | tr -d ':space:')

sed -i "s/$CURRENT_VERSION/$NEXT_VERSION/g" "$ACTION_VERSION_FILE"

mkdir "/tmp/$ACTION_PLUGIN_SLUG"

cp -ar "$ACTION_INCLUDE_FILES" "/tmp/$ACTION_PLUGIN_SLUG" 2>/dev/null
cd /tmp
zip -qr "$ACTION_OUTPUT_FILE" "$ACTION_PLUGIN_SLUG"
echo "name=output_file::${ACTION_OUTPUT_FILE}" >> "$GITHUB_OUTPUT"