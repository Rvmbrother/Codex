// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Codex",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "Codex", targets: ["Codex"])
    ],
    targets: [
        .executableTarget(
            name: "Codex",
            path: "Codex",
        )
    ]
)
