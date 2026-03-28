// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CodeSample",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "CodeSample", targets: ["CodeSample"]),
    ],
    targets: [
        .target(
            name: "CodeSample"
        ),
        .testTarget(
            name: "CodeSampleTests",
            dependencies: ["CodeSample"]
        ),
    ]
)
