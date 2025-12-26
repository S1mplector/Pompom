// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Pompom",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Pompom", targets: ["Pompom"])
    ],
    targets: [
        .executableTarget(
            name: "Pompom",
            path: "Pompom",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
