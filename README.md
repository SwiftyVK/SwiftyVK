[![SwiftyVK](./SwiftyVK_logo.png)](./)

<p align="center">
    <a href="https://cocoapods.org/pods/SwiftyVK">
    <img src="https://img.shields.io/cocoapods/p/SwiftyVK.svg?style=flat" alt="CocoaPods platforms">
  </a>
  <a href="https://developer.apple.com/swift/">
    <img src="https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat" alt="Swift 5.7">
  </a>
    <a href="https://www.swift.org/package-manager/">
    <img src="https://img.shields.io/badge/SPM-supported-brightgreen.svg?style=flat" alt="Swift Package Manager compatible">
  </a>
    <a href="https://vk.ru/dev/versions">
    <img src="https://img.shields.io/badge/VK_API->5.92-blue.svg?style=flat" alt="VK API">
  </a>
    <a href="https://cocoapods.org/pods/SwiftyVK">
    <img src="https://img.shields.io/cocoapods/v/SwiftyVK.svg?style=flat" alt="Cocoapods compatible">
  </a>
    <a href="https://github.com/Carthage/Carthage">
    <img src="https://img.shields.io/badge/Carthage-supported-brightgreen.svg" alt="Carthage compatible">
  </a>
    <a href="./LICENSE.txt">
    <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="License">
  </a>
</p>
<p align="center">
    <a href="https://github.com/SwiftyVK/SwiftyVK/actions/workflows/tests.yml">
    <img src="https://github.com/SwiftyVK/SwiftyVK/actions/workflows/tests.yml/badge.svg?branch=master" alt="GitHub Actions - Tests">
  </a>
    <a href="https://codecov.io/gh/SwiftyVK/SwiftyVK">
    <img src="https://codecov.io/gh/SwiftyVK/SwiftyVK/branch/develop/graph/badge.svg" alt="Codecov" />
  </a>
</p>
<p align="center">
   <a href="https://money.yandex.ru/to/41001399791481">
    <img src="https://img.shields.io/badge/Donate-💰-lightgrey.svg" alt="Donale">
   </a>
</p>

# Easy and powerful way to interact with [VK API](https://vk.ru/dev) for iOS and macOS.

## Key features

<p align="center">
😊 It's not <b>ios-vk-sdk</b> 😊<br />
🍏 One library for iOS and mac OS 🍏<br />
🤘 Fully written in Swift and doesn't contain any Objective-C code 🤘<br />
🎮 Very simple interface, made with care about those who will use it 🎮<br />
⛑ Fully strong typed that you can not shoot yourself in the leg ⛑<br />
🏆 High code quality with lot of unit tests, linter integration and CI 🏆<br />
🚀 Frequent updates and bug fixes 🚀<br />
🔊 LongPoll support 🔊<br />
</p>

## Table of contents
* [Requirements](#requirements)
* [Integration](#integration)
  - [Swift Package Manager](#swift-package-manager)
  - [Carthage (recommended)](#carthage-recomended)
  - [CocoaPods](#cocoapods)
  - [Manually](#manually)
* [Getting started](#getting-started)
  - [Setting up VK application](#setting-up-vk-application)
  - [Authorization](#authorization)
      - [oAuth WebView](#oauth-webview)
      - [Official VK Application](#official-vk-application)
      - [Raw token string](#raw-token-string)
* [Interaction with VK API](#interaction-with-vk-api)
  - [Request](#request)
  - [Request progress](#request-progress)
  - [Parameters](#parameters)
  - [Cancellation](#cancellation)
  - [Chaining](#chaining)
* [Configuring](#configuring)
* [Upload files](#upload-files)
* [Long Poll](#long-poll)
* [Share dialog](#share-dialog)
* [FAQ](#faq)
* [License](#license)



----
## **Requirements**
* Swift 4.0 +
* iOS 12.0 +
* macOS 10.13 +
* Xcode 9.0 +

Swift Concurrency APIs require iOS 13.0+, macOS 10.15+ and a compiler with Swift 5.5+.
No separate integration is needed: add SwiftyVK using any dependency manager below, then use its async APIs from your structured-concurrency code.
The GCD API remains available on the original deployment targets.

`Session.validate(redirectUrl:)` remains synchronous: it validates a completed OAuth redirect immediately and does not suspend. The async surface covers authorization, API requests, token events, and Long Poll events.

## **Integration**

### Swift Package Manager

> Minimum deployment targets: iOS 12.0, macOS 10.13.

Add SwiftyVK to your `Package.swift` dependencies and target as usual:

```swift
dependencies: [
    .package(url: "https://github.com/SwiftyVK/SwiftyVK.git", from: "3.4.4")
]
```

### [Carthage](https://github.com/Carthage/Carthage) (recommended)
```
github "SwiftyVK/SwiftyVK"
```

### [CocoaPods](https://github.com/CocoaPods/CocoaPods)
```ruby
use_frameworks!

target '$MySuperApp$' do
  pod 'SwiftyVK'
end
```

### Manually
  1. Just drag **SwiftyVK.framework** or include the whole **SwiftyVK.xcodeproj** into project
  2. Link **SwiftyVK.framework** with application in **Your target preferences -> General -> Embedded binaries**

## **Getting started**

For apps targeting iOS 13.0+ or macOS 10.15+, configure SwiftyVK with closures.
`VKTokenEventsStream` exposes token lifecycle events as an `AsyncStream`.
If your app does not use Swift Concurrency, see the [GCD guide](README-GCD.md).

```swift
let tokenEvents = VKTokenEventsStream()

VK.setUp(
    appId: "YOUR_APP_ID",
    scopeProvider: { _ in [.offline, .friends] },
    onViewNeedsToPresent: { viewController in
        // Present viewController from your current UI context.
    },
    tokenEvents: .stream(tokenEvents)
)

func observeTokenEvents(_ tokenEvents: VKTokenEventsStream) async {
    for await event in tokenEvents.stream {
        print(event)
    }
}
```

Run `observeTokenEvents` from your app's structured-concurrency task tree. `VK.release()` finishes the stream.
To handle token events with a callback instead, pass `tokenEvents: .callback { event in ... }`.

### Setting up VK application

1. [Create new standalone application](https://vk.ru/editapp?act=create)
2. Save `application ID` from **Preferences -> Application ID**
3. Set up **SwiftyVK** with your application ID:

```swift
VK.setUp(
    appId: "YOUR_APP_ID",
    scopeProvider: { _ in [.offline, .friends] },
    onViewNeedsToPresent: { viewController in
        // Present viewController.
    }
)
```

### Releasing

in order to free up resources that holds SwiftyVK use:

```swift
VK.release()
```
note you must setup it again for further using


## **Authorization**

SwiftyVK provides several ways to authorize user. Choose the one that's more suitable for you.

### oAuth WebView
This is a standard authorization method which shows web view with oAuth dialog. Suitable for most cases.

```swift
func authorize() async throws {
    let tokenInfo = try await VK.sessions.default.logIn()
    // Start working with SwiftyVK session here.
    print(tokenInfo)
}
```

Cancelling the Swift task immediately throws `CancellationError`; it does not dismiss an already presented authorization UI.

### Official VK Application
If a user has the official VK app installed on their device, SwiftyVK can be authorized using it. To do that:

1. In *Xcode -> Target -> Info -> URL Types*

    - Add new URL Type like `vk$YOUR_APP_ID$` (e.g. vk1234567890)
    - Add app schemas to Info.plist file:

```html
<key>LSApplicationQueriesSchemes</key>
  <array>
    <string>vkauthorize</string>
    <string>vk$YOUR_APP_ID$</string>
  </array>
```

2. Copy `Application Bundle` from
*Xcode -> $App Target$ -> General -> Bundle Identifier* (e.g. com.developer.applicationName)
2. Set copied `Application Bundle` to
*https://vk.ru/apps?act=manage -> Edit App -> Settings -> App Bundle ID for iOS* field

4. Add the following code to AppDelegate:


  - For iOS 9 and below
  
 ```swift
func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
    ) -> Bool {
    VK.handle(url: url, sourceApplication: sourceApplication)
    return true
}
```
  - For iOS 10 and above

```swift
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplicationOpenURLOptionsKey : Any] = [:]
    ) -> Bool {
    let app = options[.sourceApplication] as? String
    VK.handle(url: url, sourceApplication: app)
    return true
}
```
4. Authorize as described in [oAuth WebView](#oauth-webview).

    ***If user denies authorization in VK App, SwiftyVK will present oAuth dialog***

### Raw token string
If you have previously received user token, just pass it to the following method:

```swift
VK.sessions.default.logIn(rawToken: String, expires: TimeInterval)

// Start working with SwiftyVK session here
```

`TimeInterval` is a time, after which the token will no longer be valid. Pass `0` if you want token to never expire.

## **Interaction with VK API**

SwiftyVK provides a very simple interface for interaction with VK API.
All requests are performed asynchronously in a private queue by API scheduler
(the scheduler sends no more than 3 requests per second by default).
You can just send a request and get a response without a lot of work.

All API methods are listed [here](https://vk.ru/dev/methods)

Let's look closer to requests syntax:

### Request
The basic request calls look like **VK.methodGroup.methodName()**.

For example, to [get short info about current user](https://vk.ru/dev/users.get):

```swift
func loadCurrentUser() async throws -> Data {
    try await VK.API.Users.get(.empty).send()
}
```

Do not configure callbacks on a request that you send with `await`: the two result-handling styles are mutually exclusive.

Object created with
```swift
VK.API.Users.get(.empty)
```
represents a request that can be sent immediately or can be configured first and sent later.

### Parameters
If you want to get additional fields for a user in previous example, you can set request parameters:

```swift
VK.API.Users.get([
    .userId: "1",
    .fields: "sex,bdate,city"
    ])
```

Use `.empty` if you don't want to pass any parameters.

### Cancellation

```swift
func loadCurrentUser() async throws -> Data {
    try await VK.API.Users.get(.empty).send()
}
```

Cancellation is propagated from the parent task; `send()` throws `CancellationError` when the task is cancelled.

### Chaining

Compose requests with ordinary sequential `await` calls. Errors and cancellation propagate through the task naturally:

```swift
func sendMessage() async throws -> Data {
    let response = try await VK.API.Users.get(.empty).send()
    let user = try JSONDecoder().decode(User.self, from: response)

    return try await VK.API.Messages.send([
        .userId: user.id,
        .message: "Hello"
    ]).send()
}
```

## **Configuring**
In SwiftyVK each session has default configuration for its requests.
Each request gets configuration from its session.
Configuration contains settings such as `httpMethod`, `attemptTimeout` and others.

You can change configuration for a single request

```swift
// Set different httpMethod only for this request
VK.API.Users.get(.empty)
    .configure(with: Config(httpMethod: .POST))
```

or for the whole session

```swift
// Set default apiVersion value for all requests in default session
VK.sessions.default.config.apiVersion = "5.68"
```

You may change following configuration properties:

Property            | Default               | Description
:-------------      | -------------         | :-------------
`httpMethod`        | `.GET`                | [HTTP method](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods). You can use `GET` or `POST`. For big body (e.g. long message text in `message.send` method) use `POST` method.  
`apiVersion`        | `latest version`      | [VK API version](https://vk.ru/dev/versions). By default uses latest version. If you need different version - change this value.
`language`          | `User system language`| Language of response. For EN `Pavel Durov`, for RU `Павел Дуров`.
`attemptsMaxLimit`  | `3`                   | Maximum number of attempts to send request before returning an error.
`attemptTimeout`    | `10`                  | Timeout in seconds of waiting for a response before returning an error.
`handleErrors`      | `true`                | Allow to handle specific VK errors automatically by presenting a dialog to a user when authorization, captcha solving or validation is required.

## Request progress

Uploading requests can emit progress and a final response. Use `sendWithProgress()`:

```swift
func uploadPhoto(_ media: Media) async throws {
    for try await event in VK.API.Upload.Photo.toWall(media, to: .user(id: "4680178")).sendWithProgress() {
        switch event {
        case let .progress(progress):
            print(progress)
        case let .response(response):
            print(response)
        }
    }
}
```

The GCD `onProgress`, `onSuccess` and `onError` callbacks remain available.

## Upload files

SwiftyVK provides the ability to easily upload a file to VK servers. For example:

```swift
func uploadPhoto() async throws {
    guard let path = Bundle.main.path(forResource: "testImage", ofType: "jpg") else {
        return
    }

    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let media = Media.image(data: data, type: .jpg)

    for try await event in VK.API.Upload.Photo.toWall(media, to: .user(id: "4680178")).sendWithProgress() {
        switch event {
        case let .progress(progress):
            print(progress)
        case let .response(response):
            print(response)
        }
    }
}
```

If progress is not needed, upload methods also support the one-result API:

```swift
let response = try await VK.API.Upload.Photo.toWall(media, to: .user(id: "4680178")).send()
```

**Some upload requests do not immediately download files**


e.g `VK.API.Upload.Photo.toMessage` will return `photoId`
which you can use in `messages.send` method.
See [docs](https://vk.ru/dev/upload_files) for more info.
## Long Poll

Use the throwing event stream from a structured-concurrency context:

```swift
func consumeLongPoll() async throws {
    for try await events in VK.sessions.default.longPoll.eventsStream() {
        for event in events {
            switch event {
            case let .type1(data):
                print(JSON(data))
            default:
                break
            }
        }
    }
}
```

There may be only one Long Poll consumer: either this stream or a callback consumer.
Creating a second stream finishes it with `VKError.longPollAlreadyObserved` without stopping the first consumer.
Cancellation of the parent task propagates to `consumeLongPoll()` and stops the underlying Long Poll.
`stop()` intentionally does not stop an active async stream.

LongPollEvent has two special cases:

`.forcedStop` is returned when Long Poll experiences an unexpected error and stops. You can restart it again.

`.historyMayBeLost` is returned when Long Poll was disconnected from the server for a long time and either `lpKey` or `timestamp` is outdated. Refresh data that could have changed while the network was unavailable.

## **Share dialog**

With SwiftyVK can make a post to user wall. To do this, you need:

- [Set up SwiftyVK](#getting-started)
- [SetUp VK application](#setting-up-vk-application)
- Present share dialog with context:

```swift
let context = ShareContext(
    text: "This post made with #SwiftyVK 🖖🏽",
    images: [ShareImage(data: data, type: .jpg)],
    link: ShareLink(title: "Follow the white rabbit", url: link)
)

func share(_ context: ShareContext) async throws -> Data {
    try await VK.sessions.default.share(context)
}
```

***Images and link are optional, text is required***
***Sharing not available on macOS 10.10. If you want to use it, please make pull request to this repo.***

## **FAQ**

[I can't find some API method or parameter in library](https://github.com/SwiftyVK/SwiftyVK/wiki/I-can't-find-some-API-method-or-parameter-in-library)

## **License**

SwiftyVK is released under the MIT license.
See [LICENSE](./LICENSE.txt) for details.
