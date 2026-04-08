import UIKit

class BaseFormViewController: BaseViewController {
    var requiredFields: [UITextField] = []
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    func setupForm() {
        view.addSubview(stackView)
                
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func isFieldsChanged() -> Bool {
        return true
    }
    
    func validateFields() -> Bool {
        clearValidationStyles()
        var isValid = true
        
        for textField in requiredFields
        {
            if textField.text?.trimmed.isBlank == true {
                applyValidationStyle(textField, isValid: false)
                isValid = false
            } else {
                applyValidationStyle(textField, isValid: true)
            }
        }
        
        if !isValid {
            showAlert(Localized.emptyFields)
        }
        
        return isValid
    }
    
    private func applyValidationStyle(_ textField: UITextField, isValid: Bool) {
        if isValid {
            textField.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
            textField.layer.borderWidth = 0.5
        } else {
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1
        }
    }
    
    private func clearValidationStyles() {
        for textField in requiredFields {
            applyValidationStyle(textField, isValid: true)
        }
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        if sender.text?.trimmed.isBlank == false {
            applyValidationStyle(sender, isValid: true)
        } else {
            applyValidationStyle(sender, isValid: false)
        }
    }
}
