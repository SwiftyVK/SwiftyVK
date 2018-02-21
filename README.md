[![SwiftyVK](./SwiftyVK_logo.png)](./)

<p align="center">
    <a href="http://cocoadocs.org/docsets/SwiftyVK">
    <img src="https://img.shields.io/cocoapods/p/SwiftyVK.svg?style=flat" alt="Platform">
  </a>
  <a href="https://developer.apple.com/swift/">
    <img src="https://img.shields.io/badge/Swift-4.0.0-orange.svg?style=flat" alt="Swift">
  </a>
    <a href="https://vk.com/dev/versions">
    <img src="https://img.shields.io/badge/VK_API-5.69-blue.svg?style=flat" alt="VK API">
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
    <a href="https://travis-ci.org/SwiftyVK/SwiftyVK">
    <img src="https://travis-ci.org/SwiftyVK/SwiftyVK.svg?branch=master" alt="Build status">
  </a>
    <a href="https://codecov.io/gh/SwiftyVK/SwiftyVK">
    <img src="https://codecov.io/gh/SwiftyVK/SwiftyVK/branch/master/graph/badge.svg" alt="Codecov" />
  </a>
    <a href="https://codebeat.co/projects/github-com-swiftyvk-swiftyvk-master">
    <img src="https://codebeat.co/badges/e9f1cca3-b81d-4c6d-9129-50205465cb8a" alt="Codebeat" >
  </a>
</p>

# Easy and powerful way to interact with [VK API](https://vk.com/dev) for iOS and macOS.

## Table of contents
* [Requirements](#requirements)
* [Integration](#integration)
  - [Carthage (recomended)](#carthage-recomended)
  - [CocoaPods](#cocoapods)
  - [Manually](#manually)
* [Getting started](#getting-started)
  - [Implement SwiftyVKDelegate](#implement-swiftyvkdelegate)
  - [Setting up VK application](#setting-up-vk-application)
  - [Authorization](#authorization)
      - [oAuth WebView](#oauth-webview)
      - [Official VK Application](#official-vk-application)
      - [Raw token string](#raw-token-string)
* [Interaction with VK API](#interaction-with-vk-api)
  - [Request](#request)
  - [Parameters](#parameters)
  - [Callbacks](#callbacks)
      - [onSuccess](#onsuccess)
      - [onError](#onerror)
  - [Cancellation](#cancellation)
  - [Chaining](#chaining)
* [Configuring](#configuring)
* [Upload files](#upload-files)
* [Interaction with LongPoll](#interaction-with-longpoll)
    - [Start LongPoll](#start-longpoll)
    - [Handle updates](#handle-updates)
    - [Stop LongPoll](#stop-longpoll)
* [Share dialog](#share-dialog)
* [FAQ](#faq)
* [License](#license)



----
## **Requirements**
* Swift 4.0 +
* iOS 8.0 +
* macOS 10.10 +
* Xcode 9.0 +

## **Integration**

### [Carthage](https://github.com/Carthage/Carthage) (recomended)
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
### Implement SwiftyVKDelegate

To start using `SwiftyVK` you should implement `SwiftyVKDelegate` protocol in your custom `VKDelegate` class.
It is used to notify your app about important SwiftyVK lifecycle events.

For example:

```swift
import SwiftyVK
```

```swift
class VKDelegateExample: SwiftyVKDelegate {

    func vkNeedsScopes(for sessionId: String) -> Scopes {
      // Called when SwiftyVK attempts to get access to user account
      // Should return a set of permission scopes
    }

    func vkNeedToPresent(viewController: VKViewController) {
      // Called when SwiftyVK wants to present UI (e.g. webView or captcha)
      // Should display given view controller from current top view controller
    }

    func vkTokenCreated(for sessionId: String, info: [String : String]) {
      // Called when user grants access and SwiftyVK gets new session token
      // Can be used to run SwiftyVK requests and save session data
    }

    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
      // Called when existing session token has expired and successfully refreshed
      // You don't need to do anything special here
    }

    func vkTokenRemoved(for sessionId: String) {
      // Called when user was logged out
      // Use this method to cancel all SwiftyVK requests and remove session data
    }
}
```
*See full implementation in Example project*

### Setting up VK application

1. [Create new standalone application](https://vk.com/editapp?act=create)
2. Save `application ID` from **Preferences -> Application ID**
3. Set up **SwiftyVK** with `application ID` and `VKDelegate` obtained in the previous steps:

```swift
VK.setUp(appId: String, delegate: SwiftyVKDelegate)
```

## **Authorization**

SwiftyVK provides several ways to authorize user. Choose the one that's more suitable for you.

### oAuth WebView
This is a standard authorization method which shows web view with oAuth dialog. Suitable for most cases.

```swift
VK.sessions.default.logIn(
      onSuccess: { _ in
        // Start working with SwiftyVK session here
      },
      onError: { _ in
        // Handle an error if something went wrong
      }
  )
```

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
*https://vk.com/apps?act=manage -> Edit App -> Settings -> App Bundle ID for iOS* field

4. Add the following code to AppDelegate:


  - For iOS 9 and below

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
  - For iOS 10 and above

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
All requests are performed asynchronouly in a private queue by API scheduler
(the scheduler sends no more than 3 requests per second by default).
You can just send a request and get a response without a lot of work.

All API methods are listed [here](https://vk.com/dev/methods)

Let's look closer to requests syntax:

### Request
The basic request calls look like **VK.methodGroup.methodName()**.

For example, to [get short info about current user](https://vk.com/dev/users.get):

```swift
VK.API.Users.get(.empty)
    .onSuccess { /* handle and parse response */ }
    .onError { /* handle error */ }
    .send()
```

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

### Callbacks
Requests are executed asynchronously and provide some callbacks for handling execution results:

#### onSuccess

This callback will be called when request has succeeded and returned `Data` object.
You can handle and parse response using any JSON parsing method
(e.g. `JSONSerialization`, `Codable`, [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) and others)

```swift
VK.API.Users.get(.empty)
    .onSuccess {
        let response = try JSONSerialization.jsonObject(with: $0)
    }
```

You can throw errors in `onSuccess` callback, which will cause `onError` to be called with your error.

#### onError

This callback will be called when request has failed for some reason.
You may handle the error that was thrown in this callback.

```swift
VK.API.Users.get(.empty)
    .onError {
        print("Request failed with error: ($0)")
     }
```

### Cancellation

If you no longer need to send sheduled request (e.g. screen was popped out), just cancel it:

```swift
// `send()` function returns `Task` object which has `cancel()` function
let request = VK.API.Users.get([
    .userId: "1",
    .fields: "sex,bdate,city"
    ])
    .onSuccess { print($0) }
    .send()

// Cancel sheduled request.
// onSuccess callback will never be executed.
request.cancel()
```

### Chaining

SwiftyVK allows you to chain requests. If your second request needs to consume a response from the first one, just chain them together:

```swift
VK.API.Users.get(.empty)
    .chain { response in
        // This block will be called only
        // when `users.get` method is successfully executed.
        // Receives result of executing `users.get` method.
        let user = try JSONDecoder().decode(User.self, from: response)
        return VK.API.Messages.send([
            .userId: user.id,
            .message: "Hello"
        ])
    }
    .onSuccess { response in
        // This block will be called only when both `users.get` and `messages.send`
        // methods are successfully executed.
        // `response` is a result of `messages.send` method
    }
    .onError { error in
        // This block will be called when either `users.get` or `messages.send` methods is failed.
        // Receives error of executing `users.get` or `messages.send` method.
    }
    .send()
```

You can make very long chains with SwiftyVK!

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
`apiVersion`        | `latest version`      | [VK API version](https://vk.com/dev/versions). By default uses latest version. If you need different version - change this value.
`language`          | `User system language`| Language of response. For EN `Pavel Durov`, for RU `Павел Дуров`.
`attemptsMaxLimit`  | `3`                   | Maximum number of attempts to send request before returning an error.
`attemptTimeout`    | `10`                  | Timeout in seconds of waiting for a response before returning an error.
`handleErrors`      | `true`                | Allow to handle specific VK errors automatically by presenting a dialog to a user when authorization, captcha solving or validation is required.

## Upload files

SwiftyVK provides the ability to easily upload a file to VK servers. For example:

```swift
// Get path to image file
guard let path = Bundle.main.path(forResource: "testImage", ofType: "jpg") else { return }

// Get data from image file by path
guard let data = try Data(contentsOf: URL(fileURLWithPath: path)) else { return }

// Create SwiftyVK Media representation from given data
let media = Media.image(data: data, type: .jpg)

// Upload image to server
VK.API.Upload.Photo.toWall(media, to: .user(id: "4680178"))
    .onSuccess { print($0) }
    .onError { print($0) }
    .onProgress {
        // This callback available only for uploading requests
        // Use it to handle uploading status and show it to user
        
        switch $0 {
            case let .sent(current, of):
                print("sent", current, "of": of)
            case let .recieve(current, of):
                print("recieve", current, "of": of)
        }
    } 
    .send()
```

**Some upload requests do not immediately download files**


e.g `VK.API.Upload.Photo.toMessage` will return `photoId`
which you can use in `messages.send` method.
See [docs](https://vk.com/dev/upload_files) for more info.
## **Interaction with LongPoll**

## Start LongPoll

With SwiftyVK you can interact with VK [LongPoll](https://vk.com/dev/using_longpoll) server very easily.
Just call:

```swift
VK.sessions.default.longPoll.start {
    // This callback will be executed each time
    // long poll client receives a set of new events
    print($0)
}
```

## Handle updates

Data format is described [here](https://vk.com/dev/using_longpoll).
LongPollEvent is an enum with associated value of type `Data` in each case.
You can parse this data to JSON using your favorite parser like this:

```swift
VK.sessions.default.longPoll.start {
    for event in $0 {
        switch event {
            case let .type1(data):
                let json = JSON(data)
                print(json)
            default:
                break
        }
    }
}
```

LongPollEvent has two special cases:

`.forcedStop` - returned when LongPoll has experienced unexpected error and stop. You can restart it again.

`.historyMayBeLost` - returned when LongPoll was disconnected from server for a long time
and either `lpKey` or `timestamp` is outdated.
You do not need to reconnect LongPoll manually, client will do it itself.
Use this case to **refresh data that could have been updated while network was unavailable**.

## Stop LongPoll

If you don't need to receive LongPoll updates anymore, just call this function:
```swift
VK.sessions.default.longPoll.stop()
```

## **Share dialog**

With SwiftyVK can make a post to user wall. To do this, you need:

- [Implement SwiftyVKDelegate](#implement-swiftyvkdelegate)
- [SetUp VK application](#setting-up-vk-application)
- Present share dialog with context:

```swift
VK.sessions.default.share(
    ShareContext(
        text: "This post made with #SwiftyVK 🖖🏽",
        images: [
            ShareImage(data: data, type: .jpg), // JPG image representation
        ],
        link: ShareLink(
            title: "Follow the white rabbit", // Link description
            url: link // URL to site
        )
    ),
    onSuccess: { /* Handle response */ },
    onError: { /* Handle error */ }
```

***Images and link are optional, text is required***
***Sharing not available on macOS 10.10. If you want to use it, please make pull request to this repo.***

## **FAQ**

For now this section is empty...

## **License**

SwiftyVK is released under the MIT license.
See [LICENSE](./LICENSE.txt) for details.
