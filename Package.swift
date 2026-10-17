// swift-tools-version: 5.9
import PackageDescription

// Import-layer regression tests. The SwiftUI app remains an Xcode app scaffold.
let package = Package(
    name: "NovelReaderImport",
    platforms: [.iOS(.v17), .macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", exact: "0.9.20")
    ],
    targets: [
        .target(
            name: "NovelReaderImport",
            dependencies: [.product(name: "ZIPFoundation", package: "ZIPFoundation")],
            path: "NovelReader",
            exclude: ["ContentView.swift", "NovelReaderApp.swift", "Views", "Resources"],
            sources: ["Models", "Services"]
        ),
        .testTarget(
            name: "NovelReaderImportTests",
            dependencies: [
                "NovelReaderImport",
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "Tests/NovelReaderImportTests"
        )
    ]
)
