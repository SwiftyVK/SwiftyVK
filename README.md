# SwiftyVK - easy and powerful way to interact with [VK API](https://vk.com/dev) for iOS and macOS.

[![Swift](https://img.shields.io/badge/Swift-4.0.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![VK API](https://img.shields.io/badge/VK_API-5.62-blue.svg?style=flat)](https://vk.com/dev/versions)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyVK.svg?style=flat)](http://cocoadocs.org/docsets/SwiftyVK)
[![Build Status](https://travis-ci.org/west0r/SwiftyVK.svg?branch=master)](https://travis-ci.org/west0r/SwiftyVK)
[![Test Coverage](https://img.shields.io/codecov/c/github/west0r/SwiftyVK.svg)](https://codecov.io/gh/west0r/SwiftyVK)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftyVK.svg?style=flat)](https://cocoapods.org/pods/SwiftyVK)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-supported-brightgreen.svg)](https://github.com/west0r/SwiftyVK)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/west0r/SwiftyVK/master/LICENSE)
---
## Table of contents
* [Requirements](#requirements)
* [Integration](#integration)
  - [Manually](#manually)
  - [CocoaPods](#cocoapods)
  - [Carthage](#carthage)
* [Getting started](#getting-started)
  - [Implement SwiftyVKDelegate](#implement-swiftyvkdelegate)
  - [Setting up VK application](#setting-up-vk-application)
  - [Authorization](#authorization)
      - [Raw token string](#raw-token-string)
      - [oAuth WebView](#oauth-webview)
      - [Official VK Application](#official-vk-application)
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
* [FAQ](#faq)
* [License](#license)



----
## **Requirements**
* Swift 4.0 +
* iOS 8.0 +
* macOS 10.10 +
* Xcode 9.0 +

## **Integration**

### Manually
  1. Just drag **SwiftyVK.framework** or include the whole **SwiftyVK.xcodeproj** into project
  2. Link **SwiftyVK.framework** with application in **Your target preferences -> General -> Embedded binaries**

### [CocoaPods](https://github.com/CocoaPods/CocoaPods)
```ruby
use_frameworks!

target '$MySuperApp$' do
  pod 'SwiftyVK'
end
```

### [Carthage](https://github.com/Carthage/Carthage)
```
github "west0r/SwiftyVK"
```

## **Getting started**
### Implement SwiftyVKDelegate

For start using `SwiftyVK` you should implement `SwiftyVKDelegate` protocol in your custom `VKDelegate` class.
It is using to notify your app about important SwiftyVK lifecycle events.

For example:

```swift
import SwiftyVK
```

```swift
class VKDelegateExample: SwiftyVKDelegate {

    func vkNeedsScopes(for sessionId: String) -> Scopes {
      // Called when SwiftyVK attempts get access to user account
      // Should return set of permission scopes
    }

    func vkNeedToPresent(viewController: VKViewController) {
      // Called when SwiftyVK wants to present UI (e.g webView or captcha)
      // Should return current top view controller from your app view hierarchy
    }

    func vkTokenCreated(for sessionId: String, info: [String : String]) {
      // Called when user grant access and SwiftyVK gets new session token
      // Can be used for run SwiftyVK requests and save session data
    }

    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
      // Called when existing session token was expired and successfully refreshed
      // Most likely here you do not do anything
    }

    func vkTokenRemoved(for sessionId: String) {
      // Called when user was logged out
      // Use this point to cancel all SwiftyVK requests and remove session data
    }
}
```
*See full implementation in Example project*

### Setting up VK application

1. [Create new standalone application](https://vk.com/editapp?act=create)
2. save `application ID` from **Preferences -> Application ID**
3. Set up **SwiftyVK** with `application ID` and `VKDelegate` obtained in the previous steps:

```swift
VK.setUp(appId: String, delegate: SwiftyVKDelegate)
```

## **Authorization**

SwiftyVK provides several ways to authorize user. You may choose one that more suitable:

### Raw token string
If you already have previously received token, just put it to this method

```swift
VK.sessions?.default.logIn(rawToken: String, expires: TimeInterval)

// Start work with SwiftyVK session here
```

`TimeInterval` - token expires time interval from now. Zero value is a newer expires.

### oAuth WebView
Standard authorization method which shows webView with oAuth dialog. Suitable for most cases.

```swift
VK.sessions?.default.logIn(
      onSuccess: { _ in
        // Start work with SwiftyVK session here
      },
      onError: { _ in
        // Handle an error if something went wrong
      }
  )
```

### Official VK Application

If user have official VK application on device, SwiftyVK can be authorized through it.
For this you need:

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

4. Add this code to AppDelegate


  - For iOS 9 and bellow

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
4. Make auth like [oAuth WebView](#oauth-webview).

    ***If user deny authorization with VK App, SwiftyVK will present oAuth dialog***

## **Interaction with VK API**

SwiftyVK provides a very simple interface for interaction with VK API.
All requests performs asynchronouly in own private queue with API scheduler
(by default scheduler send no more than 3 requests per second).
You just can send it and get response without a lot of work.


List of all API methods is [here](https://vk.com/dev/methods)  

Let's look closer to requests syntax:

### Request
The base requests calls looks like **VK.methodGroup.methodName()**.

For example, [get short info about current user](https://vk.com/dev/users.get):

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
is represents a request that can be immediately sent or first configure and sent later.

### Parameters
If you want to get additional fields for concrete user in previous example, can set request parameters in this way:

```swift
VK.API.Users.get([
    .userId: "1",
    .fields: "sex,bdate,city"
    ])
```

Use `.empty` if do not want provide parameters.

### Callbacks
Request executes asynchronously and provides some callbacks for handle execution results:

#### onSuccess

This callback will be called when request was successfully executed and return `Data` object.
You can handle and parse response with any JSON parsing method
(e.g. `JSONSerialization`, `Codable`, [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) and others)

```swift
VK.API.Users.get(.empty)
    .onSuccess {
        let response = try JSONSerialization.jsonObject(with: $0)
    }
```

You can throws errors within `onSuccess` callback
and this will cause to be called `onError` callback with thrown error.

#### onError

This callback will be called when request was failed for whatever reason.
You may handle thrown error in this callback.

```swift
VK.API.Users.get(.empty)
    .onError {
        print("Request failed with error: ($0)")
     }
```

### Cancellation

If you no longer need to sent sheduled request (e.g. screen was popped out), just cancel it:

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

SwiftyVK allows make chains of requests. If you need to send next request
with data of response from previous request, just build a chain of requests:

```swift
// `send()` function returns `Task` object which has `cancel()` function
VK.API.Users.get(.empty)
    .chain {
        // This block will be called only
        // when `users.get` method is successfully executed.
        // Receives result of executing `users.get` method.
        let user = try JSONDecoder().decode(User.self, from: $0)
        return VK.API.Messages.send([
            .userId: response.user.id,
            .message: "Hello"
        ])
    }
    .onSuccess {
        // This block will be called only when `users.get` and `messages.send`
        // methods are successfully executed.
        // Receives result of executing `messages.send` method
    }
    .onError {
        // This block will be called when `users.get` or `messages.send` methods are failed.
        // Receives error of executing `users.get` or `messages.send` method.
    }
    .send()
```

You can make very long chains with SwiftyVK!

## **Configuring**
In SwiftyVK each session has default configuration for their requests.
Each request gets configuration from their session.
Configuration includes different settings such as `httpMethod`, `attemptTimeout` and others.

You can change configuration for single request

```swift
// Set different httpMethod only for this request
VK.API.Users.get(.empty)
    .configure(with: Config(httpMethod: .POST))
```

or for the whole session

```swift
// Set default apiVersion value for all requests in default session
VK.sessions?.default.config.apiVersion = "5.68"
```

You may change following configuration properties:

Property            | Default               | Description
:-------------      | -------------         | :-------------
`httpMethod`        | `.GET`                | [HTTP method](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods). You can use `GET` or `POST`. For big body (e.g. long message text in `message.send` method) use `POST` method.  
`apiVersion`        | `latest version`      | [VK API version](https://vk.com/dev/versions). By default uses latest version. If you need different version - change this value.
`language`          | `User system language`| Language of response. For EN `Pavel Durov`, for RU `Павел Дуров`.
`attemptsMaxLimit`  | `3`                   | Maximum number of attempts to send request before returning an error.
`attemptTimeout`    | `10`                  | Timeout in seconds of waiting request before returning an error.
`handleErrors`      | `true`                | Allows automatically handle specific VK errors like authorization, captcha, validation nedеed and present dialog to user for resolve this situation.

## Upload files

SwiftyVK provides ability to easily file uploading to VK servers. For example:

```swift
// Get path of image file
guard let path = Bundle.main.path(forResource: "testImage", ofType: "jpg") else { return }

// Get data from image file on given path
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
    }
    .send()
```

**Some upload requests do not immediately download files**


e.g `VK.API.Upload.Photo.toMessage` will return `photoId`
which you can use in `messages.send` method.
See [docs](https://vk.com/dev/upload_files) for more info.
## **Interaction with LongPoll**

## Start LongPoll

Also with SwiftyVK you can interract VK [LongPoll](https://vk.com/dev/using_longpoll) server very easily.
Just call:

```swift
VK.sessions?.default.longPoll.start {
    // This callback will be executed every time
    // when long poll client receive set of new events
    print($0)
}
```

## Handle updates

Data format describing on [this](https://vk.com/dev/using_longpoll) page.
LongPollEvent is enum with `Data` associated value in every case.
You can parse this data to `JSON` with any your favorite JSON parser like this

```swift
VK.sessions?.default.longPoll.start {
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

`.disconnect` - returns when LongPoll was disconnected from server.
You do not need reconnect LongPoll manually,
client will do it himself when the network connection is back again.
Use this case to display "connection not available" indicator or something else like this.

`.connect` - returns when LongPoll was connected to server again.
Use this case to display "connection available" indicator or something else like this
and **refresh data which could change during the network was unavailable**
because LongPoll do not send old events.

## Stop LongPoll

If you no longer need to receive LongPoll updates, just call this function:
```swift
VK.sessions?.default.longPoll.stop()
```

## **FAQ**

For now this section is empty...

## **License**

SwiftyVK is released under the MIT license.
See [LICENSE](https://github.com/west0r/SwiftyVK/blob/master/LICENSE.txt) for details.
