import UIKit
import SmartCodableMacro

// MARK: - 演示用模型

/// 父类：定义共享字段 + key/value 映射
class BaseModel: SmartCodableX {
    var name: String = ""
    var age: Int?
    var date: Date?
    @SmartAny var desc: Any?

    class func mappingForKey() -> [SmartKeyTransformer]? {
        [CodingKeys.name <--- "superName"]
    }

    class func mappingForValue() -> [SmartValueTransformer]? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return [CodingKeys.date <--- SmartDateTransformer(strategy: .formatted(formatter))]
    }

    func didFinishMapping() {
        print("[BaseModel] 完成解析")
    }

    required init() {}
}

/// 子类：通过 @SmartSubclass 自动生成 init/encode/CodingKeys
@SmartSubclass
class StudentModel: BaseModel {
    var location: String = ""
    var sex: Sex = .man
    var birthDate: Date?
    @SmartAny var hobbys: [Any] = []

    override static func mappingForKey() -> [SmartKeyTransformer]? {
        let trans = [CodingKeys.location <--- "sub_location"]
        if let superTrans = super.mappingForKey() {
            return superTrans + trans
        }
        return trans
    }

    override static func mappingForValue() -> [SmartValueTransformer]? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let trans = [CodingKeys.birthDate <--- SmartDateTransformer(strategy: .formatted(formatter))]
        if let superTrans = super.mappingForValue() {
            return superTrans + trans
        }
        return trans
    }

    override func didFinishMapping() {
        super.didFinishMapping()
        print("[StudentModel] 完成解析")
    }
}

enum Sex: Int, SmartCaseDefaultable {
    case man = 1
    case women = 0
}

// MARK: - 界面

final class InheritDemoViewController: UIViewController {

    private let inputTextView = UITextView()
    private let outputTextView = UITextView()
    private let runButton = UIButton(type: .system)

    private let defaultJSON = """
    {
      "superName": "Mccc",
      "age": "18",
      "desc": "good boy",
      "sub_location": "su zhou",
      "sex": 1,
      "birthDate": "2000-01-01",
      "date": "2025-05-06",
      "hobbys": ["ball", "TV"]
    }
    """

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "@SmartSubclass 演示"
        view.backgroundColor = .systemBackground
        setupUI()
        runDecoding()
    }

    private func setupUI() {
        let inputLabel = makeSectionLabel("输入 JSON（点击「运行」可重新解码）")
        let outputLabel = makeSectionLabel("解码结果与重新编码")

        inputTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        inputTextView.layer.borderColor = UIColor.separator.cgColor
        inputTextView.layer.borderWidth = 1
        inputTextView.layer.cornerRadius = 6
        inputTextView.text = defaultJSON
        inputTextView.autocapitalizationType = .none
        inputTextView.autocorrectionType = .no

        outputTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        outputTextView.layer.borderColor = UIColor.separator.cgColor
        outputTextView.layer.borderWidth = 1
        outputTextView.layer.cornerRadius = 6
        outputTextView.isEditable = false

        runButton.setTitle("运行", for: .normal)
        runButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        runButton.addTarget(self, action: #selector(runDecoding), for: .touchUpInside)

        [inputLabel, inputTextView, runButton, outputLabel, outputTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            inputLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
            inputLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            inputLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),

            inputTextView.topAnchor.constraint(equalTo: inputLabel.bottomAnchor, constant: 6),
            inputTextView.leadingAnchor.constraint(equalTo: inputLabel.leadingAnchor),
            inputTextView.trailingAnchor.constraint(equalTo: inputLabel.trailingAnchor),
            inputTextView.heightAnchor.constraint(equalToConstant: 180),

            runButton.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 8),
            runButton.centerXAnchor.constraint(equalTo: safe.centerXAnchor),

            outputLabel.topAnchor.constraint(equalTo: runButton.bottomAnchor, constant: 12),
            outputLabel.leadingAnchor.constraint(equalTo: inputLabel.leadingAnchor),
            outputLabel.trailingAnchor.constraint(equalTo: inputLabel.trailingAnchor),

            outputTextView.topAnchor.constraint(equalTo: outputLabel.bottomAnchor, constant: 6),
            outputTextView.leadingAnchor.constraint(equalTo: inputLabel.leadingAnchor),
            outputTextView.trailingAnchor.constraint(equalTo: inputLabel.trailingAnchor),
            outputTextView.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),
        ])
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }

    @objc private func runDecoding() {
        guard let model = StudentModel.deserialize(from: inputTextView.text) else {
            outputTextView.text = "❌ 解码失败"
            return
        }

        var lines: [String] = []
        lines.append("---- 解码结果 ----")
        lines.append("name      = \(model.name)")
        lines.append("age       = \(model.age.map(String.init) ?? "nil")")
        lines.append("location  = \(model.location)")
        lines.append("sex       = \(model.sex)")
        lines.append("birthDate = \(model.birthDate.map { "\($0)" } ?? "nil")")
        lines.append("date      = \(model.date.map { "\($0)" } ?? "nil")")
        lines.append("desc      = \(model.desc.map { "\($0)" } ?? "nil")")
        lines.append("hobbys    = \(model.hobbys)")
        lines.append("")
        lines.append("---- 重新编码 JSON ----")
        lines.append(model.toJSONString(prettyPrint: true) ?? "")

        outputTextView.text = lines.joined(separator: "\n")
    }
}
