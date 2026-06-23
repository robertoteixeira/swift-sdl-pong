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
            dependencies: [
                "CSDL3", 
                "CSDL3TTF"
            ]
        ),
        .systemLibrary(
            name: "CSDL3",
            pkgConfig: "sdl3",
            providers: [
                .brew(["sdl3"])
            ]
        ),
        .systemLibrary(
            name: "CSDL3TTF",
            pkgConfig: "sdl3-ttf",
            providers: [
                .brew(["sdl3_ttf"])
            ]
        )        
    ]
)
