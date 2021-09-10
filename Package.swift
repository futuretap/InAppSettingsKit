// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "InAppSettingsKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "InAppSettingsKit",
            targets: ["InAppSettingsKit"]
        ),
    ],
    targets: [
        .target(
            name: "InAppSettingsKit"
        ),
    ]
)
