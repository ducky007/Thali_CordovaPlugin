//
//  Copyright (C) Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt file in the project root
//  for full license information.
//

// This script has to be run as sudo
// Clean .jx and .npm-gyp

'use strict';

var exec = require('child-process-promise').exec;
var Promise = require('lie');
var versions = require('./validateBuildEnvironment').commandsAndResults;

function installNode() {
  return exec('npm install n')
    .catch(function (err) {
      return Promise.reject('`n` install failed with ' + err);
    })
    .then(function () {
      return exec('node_modules/n/bin/n ' + versions.node);
    })
    .catch(function (err) {
      return Promise.reject('`n` failed with ' + err);
    })
    .then(function () {
      return exec('npm install -g npm@' + versions.npm);
    })
    .catch(function (err) {
      return Promise.reject('`npm` update failed with ' + err);
    });
}

function installCordova() {
  return exec('npm install -g cordova@' + versions.cordova)
    .catch(function (err) {
      return Promise.reject('`cordova` instal failed with ' + err);
    });
}

function installHomebrew() {
  return exec('/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"')
    .catch(function (err) {
      return Promise.reject('`brew` install failed with ' + err);
    });
}

// It's needed for CI
// should be replaced with curl that already is bundled with macOS
function installWget() {
  return exec('brew install wget')
    .catch(function (err) {
      return Promise.reject('`wget` install failed with ' + err);
    });
}

function installOpenSSL() {
  return exec('brew install openssl')
    .catch(function (err) {
      return Promise.reject('`openssl` install failed with ' + err);
    })
    .then(function () {
      return exec('brew link --force openssl');
    })
    .catch(function (err) {
      return Promise.reject('`openssl` brew link failed with ' + err);
    });
}

function installJXcore() {
  var scrunchedVersion =
    versions.jxcore
      .replace(/\./g, '');

  return exec('wget http://jxcore.azureedge.net/jxcore/' + scrunchedVersion +
      '/release/jx_osx64v8.zip')
    .catch(function (err) {
      return Promise.reject('`jxcore` download failed with ' + err);
    })
    .then(function () {
      return exec('unzip jx_osx64v8.zip & cd jx_osx64v8 & cp -f jx /usr/local/bin');
    })
    .catch(function (err) {
      return Promise.reject('`jxcore` install failed with ' + err);
    });
}

function installJava() {
  return exec('brew install java')
    .catch(function (err) {
      return Promise.reject('`java` install failed with ' + err);
    });
}

function installAndroidSDK() {
  return exec('brew install android-sdk')
    .catch(function (err) {
      return Promise.reject('`android-sdk` install failed with ' + err);
    })
    .then(function () {
      var filters = [
        'tools',
        'platform-tools',
        'extra-android-m2repository',
        'extra-google-m2repository',
        'build-tools-' + versions.androidBuildTools,
        'android-' + versions.androidPlatform,
      ];

      return exec('android update sdk --no-ui --all --filter ' +
        filters.join(','));
    })
    .catch(function (err) {
      return Promise.reject('`android-sdk` install failed with ' + err);
    });
}

installHomebrew()
  .then(installNode())
  .then(installCordova())
  .then(installOpenSSL())
  .then(installWget())
  .then(installJXcore())
  .then(installJava())
  .then(installAndroidSDK());
