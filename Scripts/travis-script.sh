# Env
WORKSPACE=SwiftyVK.xcworkspace
NO_CODE_SIGNING="CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=\"\""

MAC_SCHEME="SwiftyVK_macOS"

IOS_SCHEME="SwiftyVK_iOS"
IOS_DESTANATION="platform=iOS Simulator,name=iPhone 7 Plus"

# Lint
swiftlint lint --path Library --strict \
&& xcodebuild -workspace "$WORKSPACE" -scheme "$IOS_SCHEME" -destination "$IOS_DESTANATION" "$NO_CODE_SIGNING" -enableCodeCoverage YES test | xcpretty -f `xcpretty-travis-formatter` \
&& xcodebuild -workspace "$WORKSPACE" -scheme "$MAC_SCHEME" "$NO_CODE_SIGNING" ENABLE_TESTABILITY=YES -enableCodeCoverage YES test | xcpretty -f `xcpretty-travis-formatter` \
&& pod lib lint --no-clean

