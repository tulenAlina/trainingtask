import UIKit

extension UITextField {
    static func create(text: String = "", placeholder: String, isEdit: Bool = false) -> UITextField {
        let textField = UITextField()
        if isEdit {
            textField.text = text
        }
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}
