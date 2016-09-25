//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>



#if TARGET_OS_SIMULATOR
static BOOL runInCI() {
    NSString *tmpDir = @(getenv("TMPDIR"));
    // Travis CI
    if ([tmpDir hasPrefix:@"/Users/travis"]) {
        return true;
    }
    return false;
}
#else
static BOOL runInCI() {
    return getenv("CI")
    || getenv("CONTINUOUS_INTEGRATION")
    || getenv("BUILD_ID")
    || getenv("BUILD_NUMBER")
    || getenv("TEAMCITY_VERSION")
    || getenv("TRAVIS")
    || getenv("CIRCLECI")
    || getenv("JENKINS_URL")
    || getenv("HUDSON_URL")
    || getenv("bamboo.buildKey")
    || getenv("PHPCI")
    || getenv("GOCD_SERVER_HOST")
    || getenv("BUILDKITE");
}
#endif
