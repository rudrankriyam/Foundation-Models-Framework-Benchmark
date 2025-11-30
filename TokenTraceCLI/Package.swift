// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "TokenTraceCLI",
    platforms: [
        .macOS(.v26)
    ],
    dependencies: [
        .package(path: "../BenchmarkCore"),
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.17.1")
    ],
    targets: [
        .executableTarget(
            name: "TokenTraceCLI",
            dependencies: [
                .product(name: "BenchmarkCore", package: "BenchmarkCore"),
                .product(name: "XMLCoder", package: "XMLCoder")
            ],
            path: "Sources"
        )
    ]
)
