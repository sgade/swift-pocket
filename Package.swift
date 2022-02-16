// swift-tools-version:5.5


import PackageDescription


let package = Package(
    name: "Pocket",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Pocket", targets: ["Pocket"]),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "Pocket",
            dependencies: [
                .product(name: "Swifter", package: "swifter")
            ]
        ),
        .testTarget(
            name: "PocketTests",
            dependencies: ["Pocket"]
        ),
    ]
)
