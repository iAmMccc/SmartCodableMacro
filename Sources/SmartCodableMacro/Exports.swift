// 让使用方仅 `import SmartCodableMacro` 就能获得 SmartCodable 的全部 API。
// @SmartSubclass 展开后会引用 SmartDecodable / SmartCodableX 等类型，
// 单独 import SmartCodableMacro 而不带出 SmartCodable 会导致编译失败。
@_exported import SmartCodable
