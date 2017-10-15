xcodebuild \
-workspace SwiftyVK.xcworkspace \
-scheme SwiftyVK_iOS \
-destination "platform=iOS Simulator,name=iPhone 7 Plus" \
-enableCodeCoverage YES \
CODE_SIGNING_REQUIRED=NO \
CODE_SIGN_IDENTITY="" \
test | xcpretty -f `xcpretty-travis-formatter`

