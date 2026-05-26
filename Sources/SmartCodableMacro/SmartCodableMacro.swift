@attached(member, names: named(init(from:)), named(encode(to:)), named(CodingKeys), named(init))
public macro SmartSubclass() = #externalMacro(module: "SmartCodableMacroPlugin", type: "SmartSubclassMacro")
