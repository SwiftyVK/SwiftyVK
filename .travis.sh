xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-OSX" test
xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-iOS" -destination "platform=iOS Simulator,name=iPhone 7" test
