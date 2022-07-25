// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SplitView",
    platforms: [.macOS(.v12), .iOS(.v13)],
    products: [
        .library(
            name: "SplitView",
            targets: ["SplitView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/andtie/SequenceBuilder", from: "0.0.7"),
    ],
    targets: [
        .target(
            name: "SplitView",
            dependencies: ["SequenceBuilder"]),
    ]
)
