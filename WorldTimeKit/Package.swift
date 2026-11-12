// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "WorldTimeKit",
    platforms: [.iOS(.v27), .macOS(.v27)],
    products: [
        .library(name: "WorldTimeKit", targets: ["WorldTimeKit"]),
    ],
    targets: [
        .target(name: "WorldTimeKit"),
        .testTarget(name: "WorldTimeKitTests", dependencies: ["WorldTimeKit"]),
    ]
)
