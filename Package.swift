// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "InAppSettingsKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "InAppSettingsKit",
            targets: ["InAppSettingsKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),        //

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "InAppSettingsKit",
            dependencies: [
            ],
            path: "InAppSettingsKit",
            exclude: [
                "Configurations",
                "scripts",
                "InAppSettingsKitSampleApp",
                "InAppSettingsKitTests",
                "README.md",
                "InAppSettingsKit.podspec",
                "LICENSE",
                "RELEASE_NOTES.md",
                "InAppSettingsKitFramework"
            ],
            sources: [
                "Controllers",
                "Views",
                "Models"
            ],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .headerSearchPath("Controllers"),
                .headerSearchPath("Views"),
                .headerSearchPath("Models"),
            ]
        )
    ]
)
