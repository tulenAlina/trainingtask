import UIKit

class BaseFormViewController: BaseViewController {
    var requiredFields: [UITextField] = []
    
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
    
    @objc func textFieldDidChange(sender: UITextField) {
        if sender.text?.trimmed.isBlank == false {
            applyValidationStyle(sender, isValid: true)
        } else {
            applyValidationStyle(sender, isValid: false)
        }
    }
}
