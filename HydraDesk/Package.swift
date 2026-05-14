// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "HydraDesk",
    products: [
        .executable(name: "HydraDesk", targets: ["HydraDesk"])
    ],
    targets: [
        .executableTarget(
            name: "HydraDesk",
            path: "Sources/HydraDesk"
        ),
        .testTarget(
            name: "HydraDeskTests",
            dependencies: ["HydraDesk"]
        )
    ],
    swiftLanguageModes: [.v6]
)
