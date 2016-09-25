xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-OSX" CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" test
xcodebuild -workspace SwiftyVK.xcworkspace -scheme "SwiftyVK-Example-iOS" -destination "platform=iOS Simulator,name=iPhone 7" CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" test
