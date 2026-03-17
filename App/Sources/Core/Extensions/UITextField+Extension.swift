import UIKit

extension UITextField {
    static func create(text: String = "", placeholder: String, isEdit: Bool) -> UITextField {
        let textField = UITextField()
        if isEdit {
            textField.text = text
        }
        textField.placeholder = placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}
