# SwiftyVK [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/WE-St0r/SwiftyVK/master/LICENSE) [![Platform](https://img.shields.io/cocoapods/p/SwiftyVK.svg?style=flat)](http://cocoadocs.org/docsets/SwiftyVK) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftyVK.svg?style=flat)](https://cocoapods.org/pods/SwiftyVK) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/WE-St0r/SwiftyVK) [![Swift 2.2](https://img.shields.io/badge/VK_API-5.50-blue.svg?style=flat)](https://vk.com/dev/versions) [![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)

SwiftyVK makes it easy to interact with social network "VKontakte" API for iOS and OSX.

On this page:

* [Requirements](#requirements)
* [Integration](#integration)
  * [Manually](#manually)
  * [CocoaPods](#cocoapods)
  * [Carthage](#carthage)
* [Getting started](#getting-started)
  * [Import and implementation](#import-and-implementation)
  * [Initialization](#initialization)
  * [User authorization](#user-authorization)
  * [Authorization with VK App](#authorization-with-vk-app)
* [API Requests](#api-requests)
  * [Syntax](#syntax)
  * [Custom requests](#custom-requests)
  * [Request properties](#request-properties)
  * [Default properties](#default-properties)
  * [Parsing response](#parsing-response)
  * [Error handling](#error-handling)
  * [Upload files](#upload-files)
  * [Longpoll](#longpoll)

##**Requirements**
* Swift 2.0+
* iOS 8.0+ / OSX 10.9+
* Xcode 7.0+

##**Integration**
###Manually
1. Just drag **SwiftyVK.framework** (you may need to compile it for the required platform) or include the whole **SwiftyVK.xcodeproj** to project
2. Link SwiftyVK.framework to application in **Target preferences -> General -> Embedded binaries**.



###CocoaPods
You can use [CocoaPods](https://github.com/CocoaPods/CocoaPods) to install `SwiftyVK` by adding it to `Podfile`:

```ruby
use_frameworks!

target 'MyApp' do
pod 'SwiftyVK', :git => 'https://github.com/WE-St0r/SwiftyVK.git'
end
```

###Carthage
You can use [Carthage](https://github.com/Carthage/Carthage) to install `SwiftyVK` by adding it to `Cartfile`:
```
github "WE-St0r/SwiftyVK"
```

##**Getting started**
###Import and implementation

Import **SviftyVK** to Swift file:
```swift
import SwiftyVK
```

Implement `VKDelegate` protocol and **all its functions** in custom class. For example:

```swift
class YourClass: Superclass, VKDelegate {

  func vkWillAutorize() -> [VK.Scope] {
    //Called when SwiftyVK need autorization permissions.
    return //an array of application permissions
  }

  func vkDidAutorize(parameters: Dictionary<String, String>) {}
    //Called when the user is log in. 
    //Here you can start to send requests to the API.
  }

  func vkDidUnautorize() {
    //Called when user is log out.
  }

  func vkAutorizationFailed(error: VK.Error) {
   //Called when SwiftyVK could not authorize. To let the application know that something went wrong.
  }

  func vkTokenPath() -> (useUserDefaults: Bool, alternativePath: String) {
    //Called when SwiftyVK need know where a token is located.
    return //bool value that indicates whether save token to NSUserDefaults or not, and alternative save path.
  }

  func vkWillPresentView() -> UIViewController {
    //Only for iOS!
    //Called when need to display a view from SwiftyVK.
    return //UIViewController that should present autorization view controller
  }

  func vkWillPresentWindow() -> (isSheet: Bool, inWindow: NSWindow?) {
    //Only for OSX!
    //Called when need to display a window from SwiftyVK.
    return //bool value that indicates whether to display the window as modal or not, and parent window for modal presentation
  }
}
``` 
*See full implementation in Example project*

###**Initialization**

1. [Create new standalone application](https://vk.com/editapp?act=create) and get `application ID`
2. Init **SwiftyVK** with `application ID` and `VKDelegate` object:

```swift
VK.start(appID: applicationID, delegate: VKDelegate)
```

###**User authorization**
* Implement `vkWillAutorize()` function in `VKDelegate` and return [application  permissions](https://vk.com/dev/permissions).
* Just call:


```swift
VK.autorize()
```
* And user will see authorization dialog.


###**Authorization with VK App**
For authorization with official VK application for iOS, you need:

*1. In Xcode -> Target -> Info*

* Add new URL Type with URL identifier to **URL Types** `vk$YOUR_APP_ID$` (e.g. vk1234567890)
* Add app schemas to Info.plist file:
```html
<key>LSApplicationQueriesSchemes</key>
  <array>
    <string>vkauthorize</string>
    <string>vk$YOUR_APP_ID$</string>
  </array>
```
*2. In https://vk.com/apps?act=manage -> Edit App -> Settings*

* Set `App Bundle ID for iOS` to your `App Bundle` in Xcode -> Target -> Bundle Identifier (e.g. com.developer.applicationName)

*3. Add this code to appDelegate*
```swift
func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
  VK.processURL(url, options: options)
  return true
}
```
*4. Test it!*


***If user deny authorization with VK App, SwiftyVK show standart authorization WebView in your app.***


##**API Requests**
###Syntax
The call requests is as follows **VK.methodGrop.methodName**.

For example, send request with parameters and response processing:
```swift
let req = VK.API.Users.get([VK.Arg.userId : "1"])
req.httpMethod = .Get
req.successBlock = {response in print(response)}
req.errorBlock = {error in print(error)}
req.send()
```

Or a bit shorter:
```swift
let req = VK.API.Users.get([VK.Arg.userId : "1"]).send(
  method: .Get
  success: {response in print(response)}, 
  error: {error in print(error)}
)

```
###Custom requests
You may also send special requests, such as:

* Request with custom method path:
```swift
VK.API.custom(method: "users.get", parameters: [VK.Arg.userId : "1"])
```
* [Execute request](https://vk.com/dev/execute) returns "Hello World":
```swift
VK.API.execute("return \"Hello World\"")
```
* Remote execute stored application code:
```swift
VK.API.remote(method: "YourRemoteMethodName")
```
###Request properties

The requests have several properties that control their behavior. Their names speak for themselves, but just in case I describe them:

Property | Default | Description
:------------- | ------------- | :-------------
`id`| 1... | Automatically generated id.
`httpMethod`| .GET | HTTP protocol method.
`successBlock`| empty | This code block will be executed when the response to the request.
`errorBlock` | empty | This code block will be executed, if during execution of the response fails.
`progressBlock` | empty | This code block is executed when the file is loaded. It is called every time the server sent the next part of the file.
`isAsynchronous` | true | Specifies whether the control returns after sending the request immediately or only after receiving the response. By default the requests are asynchronous and control returns immediately. Sometimes you may need to send synchronous requests, **but it is not necessary to do this in the main thread!**.
`maxAttempts` | 3 | The number of times can be resend the request automatically, if during its execution the error occurred. **0 == infinity attempts**.
`timeout` | 10 | How long in seconds a request will wait for a response from the server. If the wait is longer this value, the generated request error.
`canselled`| false | If user cancell request it will true
`catchErrors` | true | Whether to attempt **SwiftyVK** to handle some query errors automatically. Among these errors include the required authentication, captcha, exceeding the limit of requests per second.
`language` | system | The language, which will return response fields.
`log`| [String] | Request sending log.

###Default properties

In addition to the settings of each individual request, you can set global settings for **SwiftyVK**. You need to contact structure `VK.defaults`. Some fields completely duplicate the properties of requests and will be assigned to the request when it is initialized, and the other presented only in a global context.

Property | Default | Description
:------------- | ------------- | :-------------
`apiVersion`| >5.44 | Returns used VK API version
`maxRequestsPerSec` | 3 | The maximum number of requests that can be sent per second. Here you can [read more](https://vk.com/dev/api_requests) in the section "Limitations and recommendations".

##**Parsing response**

Responses to requests come in the form of text in [JSON](https://en.wikipedia.org/wiki/JSON) format. To present the data as objects, **SwiftyVK** uses the [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) library. You can refer to the documentation of the library. Here I'll describe only a short example.

In our request example about the syntax that will return the response:
```JSON
[
  {
    "id" : 1,
    "first_name" : "Pavel",
    "last_name" : "Durov"
  }
]
```

It contains an array of users which we have access to 3 fields. Suppose that we want to get all user data into separate variable. We can do this:
```swift
var id = response["0, id"].intValue //1
var firstName = response["0, first_name"].stringValue //Pavel
var lastName = response["0, last_name"].stringValue //Durov
```
And that's all You need. If You want to learn more, check out the [SwiftyJSON documentation](https://github.com/SwiftyJSON/SwiftyJSON).

##**Error handling**

In the process of request execution something can go wrong, as expected. In this case, an error is generated. **SwiftyVK** offers two ways of working with errors:

* `catchErrors == false`: SwiftyVK is **always** called the block error handling and you get to decide what to do with the error.

But sometimes it so happens that the query is executed when the user is **not authorized, requires validation / captcha entering, or simply exceeded the number of requests per second**. To automatically resolve these errors is second case.

* `catchErrors == true`: SwiftyVK **first try to handle the error**. If it contains [codes](https://vk.com/dev/errors) 5, 6, 9, 10, 14, 17, e.t.c. which arise in the above cases, the **request is resended** again after a short delay, or the **user will see a dialogue** offering to authorize, validate, or enter the captcha. If the error persists, and the number of resends of request more than `maxAttempts`, it will **call the error block**.

##**Upload files**

**SwiftyVK** allows you to easily upload files in one request by combining standard requests to VK API. Use methods in `VK.Upload` section. Let's see how you can quickly upload photos to an album:

```swift
//Get data of image
let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("image", ofType: "jpg")!)!
//Crete media object to upload
let media = Media(imageData: data, type: .JPG)
//Upload image to wall        
VK.API.Upload.Photo.toWall(media: media,
  userId: "1",
  isAsynchronous: true,
  progressBlock: { (done, total) -> () in print("upload \(done) of \(total))")},
  successBlock: {response in print(response)},
  errorBlock: {error in print(error)}
)
```

This way you can download all the other supported Vkontakte file types. Can see the implementation of other types of loading in the library tests. 

Keep in mind that in some cases, such as uploading photos to a message, using this method, you just load the file to the server and get its ID. To send a message with photo, you need to add photo ID to the message.

##**Longpoll**

If you want to use Longpoll to receive updates, **SwiftyVK** allows you to easily do this, as it contains tool for working with Longpoll.

**VK.LP** sends requests **every 25 seconds** and waits for a response. When the response is received, VK.LP **send a notification** and send next request. If the device goes to sleep, the app becomes inactive, or is lost the network, VK.LP stops and again starts working when the state is changed to the opposite. This process is fully automatic. All you need are two methods and one parameter:

```swift
VK.LP.start() //Start updating
VK.LP.isActive //Longpoll status
VK.LP.stop() //Stop updating
```

And notifications types in `VK.LP.notifications` whose codes correspond to the [codes here](https://vk.com/dev/using_longpoll)

To subscribe to the notification you just need to use standard observer:

```swift
NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UPDATE), name: VK.LP.notifications.type4, object: nil)
```
