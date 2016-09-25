xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-OSX" CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build-for-testing test-without-building
xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-iOS" -destination "platform=iOS Simulator,name=iPhone 7" CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build-for-testing test-without-building
