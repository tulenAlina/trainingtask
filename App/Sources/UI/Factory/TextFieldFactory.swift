import UIKit

enum TextFieldFactory {
    static func createDefaultTextField(text: String = "", placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.text = text
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = Colors.secondaryBackground
        textField.layer.borderWidth = BorderWidth.thin
        textField.layer.borderColor = Colors.border.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}
