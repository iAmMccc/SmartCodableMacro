import XCTest

// 故意只 import SmartCodableMacro，不 import SmartCodable，
// 用于验证 Exports.swift 中的 `@_exported import SmartCodable` 真的生效。
import SmartCodableMacro

private class ExportedSmokeBase: SmartCodableX {
    var name: String = ""

    required init() {}
}

@SmartSubclass
private class ExportedSmokeChild: ExportedSmokeBase {
    var age: Int = 0
}

final class ExportedImportSmokeTests: XCTestCase {

    func testSmartCodableTypesAreVisibleViaMacroImport() {
        let json = #"{"name":"mccc","age":7}"#
        let model = ExportedSmokeChild.deserialize(from: json)
        XCTAssertEqual(model?.name, "mccc")
        XCTAssertEqual(model?.age, 7)
    }
}
