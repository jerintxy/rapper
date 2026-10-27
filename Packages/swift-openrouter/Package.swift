// swift-tools-version: 6.2

import PackageDescription

/// Compiler settings for hand-written targets. The upstream
/// `.treatAllWarnings(as: .error)` setting is removed in this vendored copy
/// because it conflicts with Xcode's `-suppress-warnings` for packages.
let strictSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .strictMemorySafety(),
]

/// Apple platforms use URLSession; Linux uses AsyncHTTPClient because
/// FoundationNetworking's URLSession buffers whole responses (no streaming).
let applePlatforms: [Platform] = [.macOS, .macCatalyst, .iOS, .tvOS, .watchOS, .visionOS]

let package = Package(
    name: "OpenRouter",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v11), .visionOS(.v2)],
    products: [
        // Ergonomic client: `import OpenRouter`.
        .library(name: "OpenRouter", targets: ["OpenRouter"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.13.1"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.3.2"),
        .package(url: "https://github.com/apple/swift-http-types", from: "1.8.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.5.0"),
        .package(url: "https://github.com/swift-server/async-http-client", from: "1.36.2"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.104.0"),
    ],
    targets: [
        // Generated from openapi/openapi.json by Scripts/generate.sh. Do not edit.
        .target(
            name: "OpenRouterAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
            ],
        ),
        // Hand-written layer: client configuration, retries, typed errors,
        // streaming and convenience builders on top of OpenRouterAPI.
        .target(
            name: "OpenRouter",
            dependencies: [
                "OpenRouterAPI",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(
                    name: "OpenAPIURLSession",
                    package: "swift-openapi-urlsession",
                    condition: .when(platforms: applePlatforms),
                ),
                .product(
                    name: "OpenAPIAsyncHTTPClient",
                    package: "swift-openapi-async-http-client",
                    condition: .when(platforms: [.linux]),
                ),
                .product(
                    name: "AsyncHTTPClient",
                    package: "async-http-client",
                    condition: .when(platforms: [.linux]),
                ),
                .product(
                    name: "NIOCore",
                    package: "swift-nio",
                    condition: .when(platforms: [.linux]),
                ),
            ],
            swiftSettings: strictSettings,
        ),
    ],
)
