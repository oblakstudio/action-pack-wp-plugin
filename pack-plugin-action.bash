#!/bin/bash
set -e

# Check for existence of the package type variable
if [ -z "$ACTION_PACKAGE_TYPE" ]; then
  echo "Error: The global variable ACTION_PACKAGE_TYPE is not defined."
  exit 1
fi

# Function to find plugin version in PHP files and return the current version
find_plugin_version() {
  local version

  while IFS= read -r -d $'\0' file; do
    if grep -q '^\s*\* Plugin Name:' "$file"; then
      version=$(grep -oP '^\s*\*\s*Version:\s*\K.*' "$file" | tr -d '[:space:]')
      version=${version// /}  # Remove whitespace using parameter expansion
      break
    fi
  done < <(find . -maxdepth 1 -type f -name "*.php" -print0)

  echo "$version"
}

# Function to read the files and folders from .distinclude
read_distinclude() {
  local distinclude_file=".distinclude"
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      cp -ar "$line" "/tmp/$ACTION_PACKAGE_SLUG"
    fi
  done < "$distinclude_file"
}

# NEXT_VERSION=$(npm run semantic-release -- --ci=false --dry-run | grep -oP 'Published release[: ]\s*\K.*?(?=\s)')
# CURRENT_VERSION=$(find_plugin_version)

# if [ -z "$CURRENT_VERSION" ]; then
#   echo "Error: Current version not found in PHP files."
#   exit 1
# fi

# sed -i "s/$CURRENT_VERSION/$NEXT_VERSION/g" ./*.php

rm -rf "/tmp/$ACTION_PACKAGE_SLUG" 2>/dev/null
mkdir -p "/tmp/$ACTION_PACKAGE_SLUG"

# Read .distinclude and copy the files/folders if it exists
if [ -f ".distinclude" ]; then
  echo "Copying files from .distinclude"
  read_distinclude
else
  echo "Copying all files"
  cp -ar . "/tmp/$ACTION_PACKAGE_SLUG"
fi

cd /tmp
zip -qr "$ACTION_OUTPUT_FILE" "$ACTION_PACKAGE_SLUG"

echo "$NEXT_VERSION" > /tmp/VERSION
echo "name=output_file::${ACTION_OUTPUT_FILE}" >> "$GITHUB_OUTPUT"
