import UIKit

final class EditView: UIView {
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    func setupForm(rows: [(String, UIView)]) {
        addSubview(stackView)
                
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        for row in rows {
            let formRow = UIFactory.createVerticalFieldGroup(labelText: row.0, inputView: row.1)
            stackView.addArrangedSubview(formRow)
        }
    }
    
    func applyValidationResults(_ results: [(textField: UITextField, isValid: Bool)]) {
        for result in results {
            applyValidationStyle(result.textField, isValid: result.isValid)
        }
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
    
    @objc func textFieldDidChange(sender: UITextField) {
        if sender.text?.isBlank == false {
            applyValidationStyle(sender, isValid: true)
        } else {
            applyValidationStyle(sender, isValid: false)
        }
    }
}
