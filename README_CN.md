# SmartCodableMacro

[English](README.md) | 中文

[SmartCodable](https://github.com/iAmMccc/SmartCodable) 的官方继承能力扩展，提供 `@SmartSubclass` 宏，自动为子类生成 `CodingKeys`、`init(from:)`、`encode(to:)` 和 `required init()`。

> 由于该宏依赖 `swift-syntax`（首次编译需下载，体积较大），独立成包后，未使用继承能力的项目无需引入此依赖。

## 安装

要求：Swift 5.9+ / Xcode 15+。

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/iAmMccc/SmartCodableMacro.git", branch: "main")
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

`SmartCodableMacro` 已自动依赖 `SmartCodable`，无需重复声明。

## 使用

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

宏会在编译期自动生成：

- `CodingKeys` 枚举（仅子类自身字段）
- `init(from: Decoder)`：先调 `super`，再解码子类字段
- `encode(to: Encoder)`：先调 `super`，再编码子类字段
- `required init()`：若子类未自行实现

### 父类、子类同时定义 key/value 映射

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

## 示例

仓库内提供了一个完整的 iOS Demo 工程，演示父子类编解码、key/value 映射、`didFinishMapping` 回调等场景：

```
ExampleApp/ExampleApp.xcodeproj
```

直接用 Xcode 打开运行即可。该工程通过 `XCLocalSwiftPackageReference` 本地引用本仓库的 SPM 包。

## 测试

```bash
swift test
```

## 关于核心库

如果只需要解析能力（无继承），请直接使用 [SmartCodable](https://github.com/iAmMccc/SmartCodable)，更轻量、无 swift-syntax 依赖。

## License

MIT
