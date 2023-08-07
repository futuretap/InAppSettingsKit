// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "InAppSettingsKit",
    defaultLocalization: "en",
    platforms: [.iOS("10.0"), .macCatalyst("13.1")],
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
        .testTarget(
            name: "InAppSettingsKitTests",
            dependencies: [
                "InAppSettingsKit"
            ],
            resources: [
                .copy("Settings.bundle")
            ]
        ),

    ]
)
