#!/usr/bin/env bash

set -e

#xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-iOS" -destination "platform=iOS Simulator,name=iPhone 6" test

xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-OSX" test
xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-iOS" -destination "platform=iOS Simulator,name=iPhone 6" test
