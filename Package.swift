// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Extend",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v8),
        .watchOS(.v2),
        .tvOS(.v9),
    ],
    products: [
        // Custom protocols
        .library(
            name: "Protocolar",
            targets: ["Protocolar"]),
        // Custom operators
        .library(
            name: "Operator",
            targets: ["Operator"]),
        // Extend [String, Array, Date, Utils]
        .library(
            name: "Extend",
            targets: ["Extend"]),
        // Codable dynamic JSON
        .library(
            name: "JSON",
            targets: ["JSON"]),
        // Codable dynamic XML
        .library(
            name: "XML",
            targets: ["XML"]),
        // Data md5
        .library(
            name: "MD5",
            targets: ["MD5"]),
        // CoreAnimations from CALayer in QuartzCore
        .library(
            name: "CoreAnimations",
            targets: ["CoreAnimations"]),
        // RichText from NSAttributeString in Foundation
        .library(
            name: "RichText",
            targets: ["RichText"]),
        // HTTP from URLSession in Foundation
        .library(
            name: "HTTP",
            targets: ["HTTP"]),
        // HTTPClient from NIO [Empty now]
        .library(
            name: "HTTPClient",
            targets: ["HTTPClient"]),
        // HTTPServer from NIO [Empty now]
        .library(
            name: "HTTPServer",
            targets: ["HTTPServer"]),
        // HTTPServer from NIO [Empty now]
        .library(
            name: "SocketClient",
            targets: ["SocketClient"]),
        // HTTPServer from NIO [Empty now]
        .library(
            name: "SocketServer",
            targets: ["SocketServer"]),
        // SQL in Swift
        .library(
            name: "DataBase",
            targets: ["DataBase"]),
        // SQLite with
        .library(
            name: "SQLite",
            targets: ["SQLite"]),
        // MySQL with [Empty now]
        .library(
            name: "MySQL",
            targets: ["MySQL"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Protocolar",
            dependencies: []),
        .target(
            name: "Operator",
            dependencies: ["Protocolar"]),
        .target(
            name: "Extend",
            dependencies: ["Protocolar", "Operator"],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]),
        .testTarget(
            name: "ExtendTests",
            dependencies: ["Extend"]),
        .target(
            name: "CoreAnimations",
            dependencies: [],
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("QuartzCore"),
            ]),
        .target(
            name: "JSON",
            dependencies: [],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]),
        .target(
            name: "XML",
            dependencies: [],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]),
        .target(
            name: "MD5",
            dependencies: []),
        .target(
            name: "HTTP",
            dependencies: ["MD5","Extend"]),
        .target(
            name: "HTTPClient",
            dependencies: []),
        .target(
            name: "HTTPServer",
            dependencies: []),
        .target(
            name: "SocketClient",
            dependencies: []),
        .target(
            name: "SocketServer",
            dependencies: []),
        .target(
            name: "DataBase",
            dependencies: []),
        .testTarget(
            name: "DataBaseTests",
            dependencies: ["DataBase"]),
        .target(
            name: "SQLite",
            dependencies: ["DataBase"],
            linkerSettings: [
                .linkedLibrary("sqlite3"),
            ]),
        .target(
            name: "MySQL",
            dependencies: ["DataBase"]),
        .target(
            name: "RichText",
            dependencies: []),

    ]
)
