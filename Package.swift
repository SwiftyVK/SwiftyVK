// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "SwiftyVK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13)
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
            dependencies: [
                .target(name: "SwiftyVK_resources_iOS", condition: .when(platforms: [.iOS])),
                .target(name: "SwiftyVK_resources_macOS", condition: .when(platforms: [.macOS]))
            ],
            path: "Library",
            exclude: [
                "SwiftyVK.xcodeproj",
                "Tests",
                "Sources/SwiftyVK.h",
                "Resources/Files",
                "Resources/Info",
                "Resources/Bundles"
            ],
            sources: [
                "Sources",
                "UI"
            ],
            linkerSettings: [
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("WebKit")
            ]
        ),
        .target(
            name: "SwiftyVK_resources_iOS",
            path: "Sources/SwiftyVK_resources_iOS",
            resources: [
                .copy("../../Library/Resources/Bundles/SwiftyVK_resources_iOS.bundle")
            ]
        ),
        .target(
            name: "SwiftyVK_resources_macOS",
            path: "Sources/SwiftyVK_resources_macOS",
            resources: [
                .copy("../../Library/Resources/Bundles/SwiftyVK_resources_macOS.bundle")
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
