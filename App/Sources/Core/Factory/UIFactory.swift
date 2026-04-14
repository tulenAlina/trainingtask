import UIKit

enum UIFactory {
    static func createDefaultTextField(text: String = "", placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.text = text
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    static func createDefaultLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createVerticalFieldGroup(labelText: String, inputView: UIView) -> UIStackView {
        let label = createDefaultLabel(text: labelText)
        
        let stack = UIStackView(arrangedSubviews: [label, inputView])
        stack.axis = .vertical
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }
    
    static func createDeleteButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(Localized.delete, for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
