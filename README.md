# SmartCodableMacro

English | [中文](README_CN.md)

The official inheritance extension for [SmartCodable](https://github.com/iAmMccc/SmartCodable). Provides the `@SmartSubclass` macro that auto-generates `CodingKeys`, `init(from:)`, `encode(to:)`, and `required init()` for subclasses.

> This macro depends on `swift-syntax` (a large first-time download). Shipping it as a separate package keeps the core SmartCodable library lightweight for projects that don't need class inheritance.

## Installation

Requirements: Swift 5.9+ / Xcode 15+.

> 🚧 **Currently in beta.** The latest version is `1.0.0-beta.1`, paired with SmartCodable `7.0.0-beta.1`.
> Use `exact:` to opt in — SPM's `from:` does not match prerelease versions.

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/iAmMccc/SmartCodableMacro.git", exact: "1.0.0-beta.1")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "SmartCodableMacro", package: "SmartCodableMacro")
        ]
    )
]
```

Once 1.0 is stable, switch to:

```swift
dependencies: [
    .package(url: "https://github.com/iAmMccc/SmartCodableMacro.git", from: "1.0.0")
]
```

`SmartCodableMacro` automatically depends on `SmartCodable` — no need to declare it separately.

## Usage

```swift
import SmartCodable
import SmartCodableMacro

class BaseModel: SmartCodableX {
    var name: String = ""
    required init() {}
}

@SmartSubclass
class StudentModel: BaseModel {
    var age: Int = 0
}
```

At compile time, the macro auto-generates:

- A `CodingKeys` enum (only the subclass's own fields)
- `init(from: Decoder)` — calls `super` first, then decodes the subclass's fields
- `encode(to: Encoder)` — calls `super` first, then encodes the subclass's fields
- `required init()` — only if the subclass doesn't define one

### Key/value mapping in both base and subclass

```swift
class BaseModel: SmartCodableX {
    var name: String = ""
    required init() {}
    class func mappingForKey() -> [SmartKeyTransformer]? {
        [CodingKeys.name <--- "stu_name"]
    }
}

@SmartSubclass
class StudentModel: BaseModel {
    var age: Int = 0
    override static func mappingForKey() -> [SmartKeyTransformer]? {
        let trans = [CodingKeys.age <--- "stu_age"]
        if let superTrans = super.mappingForKey() {
            return trans + superTrans
        }
        return trans
    }
}
```

## Example

The repo includes a full iOS demo project covering parent/child encode-decode, key/value mapping, and the `didFinishMapping` callback:

```
ExampleApp/ExampleApp.xcodeproj
```

Open it directly in Xcode. The project references this package locally via `XCLocalSwiftPackageReference`.

## Tests

```bash
swift test
```

## About the Core Library

If you only need parsing (no inheritance), use [SmartCodable](https://github.com/iAmMccc/SmartCodable) directly — it's lighter and has no `swift-syntax` dependency.

## License

MIT
