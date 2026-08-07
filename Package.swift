// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TelegramMD3",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TelegramMD3",
            targets: ["TelegramMD3"]),
    ],
    targets: [
        .target(
            name: "TelegramMD3",
            path: "TelegramMD3"
        )
    ]
)
