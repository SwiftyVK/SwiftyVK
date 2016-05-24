#!/usr/bin/env bash

set -e

xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-OSX" test CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""
xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-iOS" -destination "platform=iOS Simulator,name=iPhone 6" test CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""
