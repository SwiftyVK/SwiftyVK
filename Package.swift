// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "SwiftyVK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftyVK",
            targets: ["SwiftyVK"]
        )
    ],
    targets: [
        .target(
            name: "SwiftyVK",
            path: "Library",
            exclude: [
                "SwiftyVK.xcodeproj",
                "Tests",
                "Sources/SwiftyVK.h",
                "Resources/Bundles",
                "Resources/Files",
                "Resources/Info",
                "UI/macOS"
            ],
            sources: [
                "Sources",
                "UI"
            ],
            resources: [
                .copy("Resources/Bundles/SwiftyVK_resources_iOS.bundle")
            ],
            linkerSettings: [
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("WebKit")
            ]
        ),
        .testTarget(
            name: "SwiftyVKTests",
            dependencies: ["SwiftyVK"],
            path: "Library/Tests",
            resources: [
                .process("Data")
            ]
        )
    ]
)
