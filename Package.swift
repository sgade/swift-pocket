// swift-tools-version:5.5


import PackageDescription


let package = Package(
    name: "Pocket",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "Pocket", targets: ["Pocket"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Pocket",
            dependencies: []
        ),
        .testTarget(
            name: "PocketTests",
            dependencies: ["Pocket"]
        ),
    ]
)
