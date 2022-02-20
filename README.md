# swift-pocket

[Pocket API](https://getpocket.com/developer/) for Swift.

## Usage

Before you can use the API, you need to [obtain a consumer key](http://getpocket.com/developer/apps/new).
You can start using the package by creating a new `Pocket` instance and passing your consumer key:

```swift
let pocket = Pocket(consumerKey: "...")
```

### Note on asynchronous functions

All asynchronous calls implement Swift's async/await feature. There are also callback-based implementations available. 

### Authorization

The instance needs to be authenticated with the user's account. This is done via the user's consent in the browser.

1. Obtain a request token that you can later use to obtain your access token.
2. Listen on the redirect url you provided to notice when the authorization has been granted by the user.
3. Direct the user to the authorization url.
4. You can obtain your access token.

```swift
// (1)
let requestToken = try await pocket.obtainRequestToken(forRedirectingTo: redirectUrl)
// (2)
// Listen on your redirectUrl, e.g. "http://localhost:44444/callback" using a local webserver
// (3)
let authorizationUrl = pocket.buildAuthorizationUrl(for: requestToken, redirectingTo: redirectUrl)
// (4)
let accessToken = try await pocket.obtainAccessToken(for: requestToken)
```

Using that instance, you can invoke actions against the api.

### Saving the access token for future use

You can retrieve the access token from the `accessToken` property.
Use this to save and restore the token for future uses.

### Add an item to the queue

```swift
let parameters = Pocket.AddParameters(url: url)
// add parameters by configuring the AddParameters object
try await pocket.add(item: parameters)
```

### Retrieve items from the queue

```swift
let parameters = Pocket.RetrieveParameters()
// change filter options by configuring the RetrieveParameters object
let items = try await pocket.retrieve(with: parameters)
```

### Archive item from the queue

```swift
let itemId = 123
try await pocket.archive(itemIds: [itemId])
```

## Installation

Using the Swift Package Manager, add this line to your `Package.swift` as a dependency:

```swift
    .package(url: "https://github.com/sgade/swift-pocket", from: "1.0.0"),
```

## License

See `LICENSE` file.
