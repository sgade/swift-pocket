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
