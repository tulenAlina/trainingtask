import UIKit

struct FormRow {
    let labelText: String
    let inputView: UIView
}

struct ValidationResult {
    let textField: UITextField
    let isValid: Bool
}

final class ValidatableFormView: UIView {
    private let contentScrollView = ScrollableStackView(views: [], spacing: Spacing.medium)
    
    func setupForm(rows: [FormRow]) {
        setupScrollView()
        addRows(rows: rows)
    }
    
    func applyValidationResults(_ results: [ValidationResult]) {
        for result in results {
            applyValidationStyle(result.textField, isValid: result.isValid)
        }
    }
    
    func applyValidationStyle(_ textField: UITextField, isValid: Bool) {
        if isValid {
            textField.layer.borderColor = Colors.validBorder.cgColor
            textField.layer.borderWidth = BorderWidth.thin
        } else {
            textField.layer.borderColor = Colors.invalidBorder.cgColor
            textField.layer.borderWidth = BorderWidth.normal
        }
    }
    
    private func setupScrollView() {
        addSubview(contentScrollView)
                
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Spacing.medium),
            contentScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.extraLarge),
            contentScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.extraLarge),
            contentScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.medium)
        ])
    }
    
    private func addRows(rows: [FormRow]) {
        for row in rows {
            let formRow = UIFactory.createVerticalFieldGroup(labelText: row.labelText, inputView: row.inputView)
            contentScrollView.addArrangedSubview(formRow)
        }
    }
}
