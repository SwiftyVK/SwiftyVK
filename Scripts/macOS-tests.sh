xcodebuild \
-workspace SwiftyVK.xcworkspace \
-scheme SwiftyVK_macOS \
-enableCodeCoverage YES \
CODE_SIGNING_REQUIRED=NO \
CODE_SIGN_IDENTITY="" \
ENABLE_TESTABILITY=YES \
test | xcpretty -f `xcpretty-travis-formatter`
