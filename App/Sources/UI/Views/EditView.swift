import UIKit

final class EditView: UIView {
    private let contentScrollView = ScrollableStackView(views: [], spacing: 10)
    
    func setupForm(rows: [(String, UIView)]) {
        addSubview(contentScrollView)
                
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            contentScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        for row in rows {
            let formRow = UIFactory.createVerticalFieldGroup(labelText: row.0, inputView: row.1)
            contentScrollView.addArrangedSubview(formRow)
        }
    }
    
    func applyValidationResults(_ results: [(textField: UITextField, isValid: Bool)]) {
        for result in results {
            applyValidationStyle(result.textField, isValid: result.isValid)
        }
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        if sender.text?.isBlank == false {
            applyValidationStyle(sender, isValid: true)
        } else {
            applyValidationStyle(sender, isValid: false)
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
}
