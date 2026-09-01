# SwiftyVK: GCD way

This guide covers SwiftyVK's callback-based API. For installation, VK application setup, request parameters, configuration and media types, see the [main README](README.md).

## Requirements

The GCD way supports the original library deployment targets: iOS 12.0+ and macOS 10.13+.

## Table of contents

* [Setup](#setup)
* [Authorization](#authorization)
* [Requests](#requests)
  - [Callbacks](#callbacks)
  - [Cancellation](#cancellation)
  - [Chaining](#chaining)
* [Upload files](#upload-files)
* [Long Poll](#long-poll)
* [Share dialog](#share-dialog)

## Setup

Implement `SwiftyVKDelegate` in your app. It supplies permission scopes, presents SwiftyVK UI and receives token lifecycle callbacks.

```swift
final class VKDelegateExample: SwiftyVKDelegate {
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        [.offline, .friends]
    }

    func vkNeedToPresent(viewController: VKViewController) {
        // Present viewController from your current UI context.
    }

    func vkTokenCreated(for sessionId: String, info: [String: String]) {
        print("token created: \(info)")
    }

    func vkTokenUpdated(for sessionId: String, info: [String: String]) {
        print("token updated: \(info)")
    }

    func vkTokenRemoved(for sessionId: String) {
        print("token removed: \(sessionId)")
    }
}

let delegate = VKDelegateExample()
VK.setUp(appId: "YOUR_APP_ID", delegate: delegate)
```

Keep the delegate alive for as long as SwiftyVK is configured.

## Authorization

```swift
VK.sessions.default.logIn(
    onSuccess: { tokenInfo in
        // Start working with the session.
        print(tokenInfo)
    },
    onError: { error in
        print("Authorization failed: \(error)")
    }
)
```

## Requests

```swift
VK.API.Users.get(.empty)
    .onSuccess { response in
        print(response)
    }
    .onError { error in
        print("Request failed: \(error)")
    }
    .send()
```

### Callbacks

`onSuccess` receives the response `Data`. Throwing from `onSuccess` invokes `onError` with that error.

```swift
VK.API.Users.get(.empty)
    .onSuccess { response in
        let json = try JSONSerialization.jsonObject(with: response)
        print(json)
    }
    .onError { error in
        print(error)
    }
    .send()
```

### Cancellation

`send()` returns a library `Task`. Cancel it when the result is no longer needed.

```swift
let request = VK.API.Users.get([
    .userId: "1",
    .fields: "sex,bdate,city"
])
.onSuccess { print($0) }
.send()

request.cancel()
```

### Chaining

Use `.chain` when the next request depends on the previous response:

```swift
VK.API.Users.get(.empty)
    .chain { response in
        let user = try JSONDecoder().decode(User.self, from: response)
        return VK.API.Messages.send([
            .userId: user.id,
            .message: "Hello"
        ])
    }
    .onSuccess { response in
        print(response)
    }
    .onError { error in
        print(error)
    }
    .send()
```

## Upload files

```swift
let media = Media.image(data: data, type: .jpg)

VK.API.Upload.Photo.toWall(media, to: .user(id: "4680178"))
    .onProgress { progress in
        print(progress)
    }
    .onSuccess { response in
        print(response)
    }
    .onError { error in
        print(error)
    }
    .send()
```

## Long Poll

Only one Long Poll consumer may be active. Use either this callback API or the Swift Concurrency event stream from the [main README](README.md#long-poll-swift-concurrency-way).

```swift
VK.sessions.default.longPoll.start {
    for event in $0 {
        switch event {
        case let .type1(data):
            print(JSON(data))
        default:
            break
        }
    }
}
```

`LongPollEvent.forcedStop` means Long Poll stopped after an unexpected error; you can start it again. `LongPollEvent.historyMayBeLost` means the connection was stale and data should be refreshed.

Stop the callback consumer when it is no longer needed:

```swift
VK.sessions.default.longPoll.stop()
```

## Share dialog

```swift
let context = ShareContext(
    text: "This post made with #SwiftyVK 🖖🏽",
    images: [ShareImage(data: data, type: .jpg)],
    link: ShareLink(title: "Follow the white rabbit", url: link)
)

VK.sessions.default.share(
    context,
    onSuccess: { response in
        print(response)
    },
    onError: { error in
        print(error)
    }
)
```
