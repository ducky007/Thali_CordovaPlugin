#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if we are running in MinGW
runningInMinGw=false

if [ "$(uname -s | cut -c 1-5)" == "MINGW" ]; then
    echo "Running in MinGW"
    runningInMinGw=true
fi

# Set variables

TEST_PROJECT_NAME=ThaliTest

# The first argument must be the name of the test file to make into the app.js
# The second argument is optional and specifies a string with an IP address to
# manually set the coordination server's address to.
# The third argument is optional and if set causes copying of the android unit tests
# to platforms/android

cd `dirname $0`
cd ../..
repositoryRoot=$(pwd)
cd test/TestServer
jx npm install
# jx generateServerAddress.js $2
cd $repositoryRoot/..
cordova create $TEST_PROJECT_NAME com.test.thalitest $TEST_PROJECT_NAME
mkdir -p $TEST_PROJECT_NAME/thaliDontCheckIn/localdev

if [ $runningInMinGw == true ]; then
    # The thali package might be installed as link and there will
    # be troubles later on if this link is tried to be copied so
    # remove it here.
    rm -rf $repositoryRoot/test/www/jxcore/node_modules/thali
    cp -R $repositoryRoot/test/www/ $TEST_PROJECT_NAME/
else

    rsync -a --no-links $repositoryRoot/test/www/ $TEST_PROJECT_NAME/www
fi

cd $TEST_PROJECT_NAME
# TODO Temporarily disabling ios build
#cordova platform add ios
cordova platform add android
cd www/jxcore
jx npm install $repositoryRoot/thali --save --no-optional --autoremove "*.gz"

if [ $runningInMinGw == true ]; then
    # On Windows the package.json file will contain an invalid local file URI for Thali,
    # which needs to be replaced with a valid value. Otherwise the build process
    # will be aborted. Restore write permission after running sed in case
    # Windows security settings removed it.
    sed -i 's/"thali": ".*"/"thali": "*"/g' package.json
    chmod 644 package.json
fi

# SuperTest which is used by some of the BVTs include a PEM file (for private
# keys) that makes Android unhappy so we remove it below in addition to the gz
# files.
jx npm install --no-optional --autoremove "*.gz,*.pem"

# In case autoremove fails to delete the files, delete them explicitly.
find . -name "*.gz" -delete
find . -name "*.pem" -delete

cp -v $1 app.js

# In case of UT create a file
if [ $2 == "UT" ] || [ $3 == "UT" ] ; then
  echo "UT files will be copied to the platform directory"
  touch ../../platforms/android/unittests
fi

cordova build android --release --device

# TODO Temporarily disabling ios build
#if [ $runningInMinGw == false ]; then
  SETUP_XCODE_TESTS_SCRIPT_PATH=$repositoryRoot/thali/install/setupXcodeProjectTests.js
  TEST_PROJECT_PATH=$repositoryRoot/../$TEST_PROJECT_NAME/platforms/ios/$TEST_PROJECT_NAME.xcodeproj
  FRAMEWORK_PROJECT_FOLDER_PATH=$repositoryRoot/../$TEST_PROJECT_NAME/plugins/org.thaliproject.p2p/lib/ios/ThaliCore

  # updates Xcode project for CI stuff
  jx $SETUP_XCODE_TESTS_SCRIPT_PATH "${TEST_PROJECT_PATH}" "${FRAMEWORK_PROJECT_FOLDER_PATH}"

  # build iOS
  cordova build ios --device
#fi

echo "Remember to start the test coordination server by running jx index.js"
