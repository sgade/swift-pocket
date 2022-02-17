# swift-pocket

[Pocket API](https://getpocket.com/developer/) for Swift.

## Usage

Before you can use the API, you need to [obtain a consumer key](http://getpocket.com/developer/apps/new).
You can start using the package by creating a new `Pocket` instance:

```swift
let pocket = Pocket(consumerKey: "...")
```

Next, the instance needs to be authenticated with the user's account:

```swift
try pocket.obtainAccessToken(using: redirectUrl)
```

Using that instance, you can invoke actions against the api.

### Add an item to the queue

```swift
let parameters = Pocket.AddParameters(url: url)
// add parameters by configuring the AddParameters object
try pocket.add(with: parameters)
```

### Retrieve items from the queue

```swift
let parameters = Pocket.RetrieveParameters()
// change filter options by configuring the RetrieveParameters object
let items = try pocket.retrieve(with: parameters)
```

### Archive item from the queue

```swift
let itemId = 123
try pocket.archive(itemId: itemId)
```

## Installation

Using the Swift Package Manager, add this line to your `Package.swift` as a dependency:

```swift
    .package(url: "https://github.com/sgade/swift-pocket", from: "1.0.0"),
```
