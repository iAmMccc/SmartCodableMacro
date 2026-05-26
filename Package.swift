// swift-tools-version: 5.9
import CompilerPluginSupport
import PackageDescription

#if compiler(>=6.3)
let swiftSyntaxVersion: Version = "603.0.0"
#elseif compiler(>=6.2)
let swiftSyntaxVersion: Version = "602.0.0"
#elseif compiler(>=6.1)
let swiftSyntaxVersion: Version = "601.0.0"
#elseif compiler(>=6.0)
let swiftSyntaxVersion: Version = "600.0.0"
#elseif compiler(>=5.10)
let swiftSyntaxVersion: Version = "510.0.0"
#else
let swiftSyntaxVersion: Version = "509.0.0"
#endif

let package = Package(
    name: "SmartCodableMacro",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SmartCodableMacro",
            targets: ["SmartCodableMacro"]
        )
    ],
    dependencies: [
        // beta 期间使用 exact —— SPM 的 from: 不会匹配 prerelease 版本。
        // SmartCodable 7.0 正式版发布后，可改为：
        // .package(url: "https://github.com/iAmMccc/SmartCodable.git", from: "7.0.0")
        .package(url: "https://github.com/iAmMccc/SmartCodable.git", exact: "7.0.0-beta.1"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: swiftSyntaxVersion)
    ],
    targets: [
        .macro(
            name: "SmartCodableMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "SmartCodableMacro",
            dependencies: [
                .product(name: "SmartCodable", package: "SmartCodable"),
                "SmartCodableMacroPlugin"
            ]
        ),
        .testTarget(
            name: "SmartCodableMacroTests",
            dependencies: [
                "SmartCodableMacro",
                "SmartCodableMacroPlugin",
                .product(name: "SmartCodable", package: "SmartCodable"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
