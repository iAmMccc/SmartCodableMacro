import Foundation
import SmartCodable
import SmartCodableMacro

/// @SmartSubclass 父类：提供 name 字段
class SmartSubclassBaseModel: SmartCodableX {
    var name: String = ""

    required init() {}
}

/// 单层继承子类：age 字段 + lazy desc（不参与编解码）
@SmartSubclass
class SmartSubclassModel: SmartSubclassBaseModel {
    var age: Int = 0

    lazy var desc: String = "我的名字是\(self.name)"
}

/// 多层继承链：祖父(name) → 父(height) → 子(age)
class SmartSubclassMultiLevelBaseModel: SmartCodableX {
    var name: String = ""

    required init() {}
}

@SmartSubclass
class SmartSubclassMiddleModel: SmartSubclassMultiLevelBaseModel {
    var height: Int = 0
}

@SmartSubclass
class SmartSubclassMultiLevelModel: SmartSubclassMiddleModel {
    var age: Int = 0
}

/// 只读属性包装器：验证 @propertyWrapper 在继承链中的兼容性
@propertyWrapper
struct SingleValueReadOnly<Value: Codable>: Codable {
    let wrappedValue: Value

    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

/// 带 @propertyWrapper 的继承模型基类
class WrappedBaseModel: SmartCodableX {
    var name: String = ""

    required init() {}
}

/// age 使用 SingleValueReadOnly 包裹的子类
@SmartSubclass
class WrappedSubModel: WrappedBaseModel {
    @SingleValueReadOnly var age: Int = 0
}

/// 自定义 required init 的子类：验证宏不重复生成 init()
@SmartSubclass
class SmartSubclassModelWithCustomRequiredInit: SmartSubclassBaseModel {
    var age: Int = 0

    required init() {
        super.init()
        age = 7
    }
}
