// swift-tools-version: 5.7
import PackageDescription

let localizations = ["be", "de", "en", "es", "fi", "it", "ru", "uk"]

let iOSResources: [Resource] = [
    .process("Asset.xcassets"),
    .process("Base.lproj/Storyboard_iOS.storyboard")
] + localizations.flatMap { localization in
    [
        .process("\(localization).lproj/Localizable.strings"),
        .process("\(localization).lproj/Storyboard_iOS.strings")
    ]
}

let macOSResources: [Resource] = [
    .process("Asset.xcassets"),
    .process("Base.lproj/Storyboard_macOS.storyboard"),
    .process("ShareImageCollectionViewItem_macOS.xib")
] + localizations.flatMap { localization in
    [
        .process("\(localization).lproj/Localizable.strings"),
        .process("\(localization).lproj/Storyboard_macOS.strings")
    ]
}

let iOSResourceExcludes = [
    "BundleProviderMacOS.swift",
    "ShareImageCollectionViewItem_macOS.xib",
    "Base.lproj/Storyboard_macOS.storyboard"
] + localizations.map { "\($0).lproj/Storyboard_macOS.strings" }

let macOSResourceExcludes = [
    "BundleProviderIOS.swift",
    "Base.lproj/Storyboard_iOS.storyboard"
] + localizations.map { "\($0).lproj/Storyboard_iOS.strings" }

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
                .target(name: "SwiftyVKResourcesIOS", condition: .when(platforms: [.iOS])),
                .target(name: "SwiftyVKResourcesMacOS", condition: .when(platforms: [.macOS]))
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
            name: "SwiftyVKResourcesIOS",
            path: "Library/Resources/Files",
            exclude: iOSResourceExcludes,
            sources: [
                "BundleProviderIOS.swift"
            ],
            resources: iOSResources
        ),
        .target(
            name: "SwiftyVKResourcesMacOS",
            path: "Library/Resources/Files",
            exclude: macOSResourceExcludes,
            sources: [
                "BundleProviderMacOS.swift"
            ],
            resources: macOSResources
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
