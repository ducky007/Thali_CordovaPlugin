#!/bin/sh
#
#  Copyright (C) Microsoft. All rights reserved.
#  Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
#

XCODE_VERSION=7.3.1
NODE_VERSION=6.5.0
CORDOVA_VERSION=6.3.0

command_exist() {
  command_name=$1

  if [ -x "$(command -v ${command_name})" ]; then
    echo "${command_name} is installed"
  else
    echo "${command_name} is not installed"
  fi
}

fetch_xcode_version() {
  xcodebuild -version | grep Xcode | awk -F" " '{print $2}'
}

validate_xcode() {
  echo "Validating Xcode requirements..."

  command_exist "xcodebuild"

  required_version=$1
  current_version=$(fetch_xcode_version)

  echo "Xcode ${current_version}"

  if [ $current_version = $required_version ]; then
    echo "Xcode matches required ${required_version}"
  else
    echo "Xcode doesn't match ${required_version}"
    exit 1
  fi

  echo "\n"
}

fetch_cordova_version() {
  cordova --version
}

validate_cordova() {
  echo "Validating Cordova requirements..."

  command_exist "cordova"

  required_version=$1
  current_version=$(fetch_cordova_version)

  echo "Cordova ${current_version}"

  if [ $current_version = $required_version ]; then
    echo "Cordova matches required ${required_version}"
  else
    echo "Cordova doesn't match ${required_version}"
    exit 1
  fi

  echo "\n"
}

fetch_node_version() {
  node --version | awk -F"v" '{print $2}'
}

validate_node() {
  echo "Validating Node requirements..."

  command_exist "node1"

  required_version=$1
  current_version=$(fetch_node_version)

  echo "Node ${current_version}"

  if [ $current_version = $required_version ]; then
    echo "Node matches required ${required_version}"
  else
    echo "Node doesn't match ${required_version}"
    exit 1
  fi

  echo "\n"
}

validate_xcode ${XCODE_VERSION}

# Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Node.js and Cordova
brew install node
brew switch node ${NODE_VERSION}
npm install -g cordova@${CORDOVA_VERSION}

# Install Android dependencies
brew install android-sdk
# find line with `SDK Platform Android 5.0.1, API 21` and get its id
# find line with `Android SDK Tools` and get its id
# find line with `Android SDK Platform-tools` and get its id
# find line with `Android SDK Build-tools` and get first id
# btw we can install proper sdk with gradle, see https://github.com/codepath/android_guides/wiki/Installing-Android-SDK-Tools
android list sdk --all # TODO fetch ids for --filter
android update sdk --no-ui --all --filter 1,2,3,...,n # use proper ids

# Install iOS dependencies
brew install swiftlint

# validate_cordova 6.3.0
# validate_node 6.5.0
