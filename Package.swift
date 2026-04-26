// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSDLPong",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "SwiftSDLPong",
            dependencies: ["CSDL3"]
        ),
        .systemLibrary(
            name: "CSDL3",
            pkgConfig: "sdl3",
            providers: [
                .brew(["sdl3"])
            ]
        )
    ]
)
