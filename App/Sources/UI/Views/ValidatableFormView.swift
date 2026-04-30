import UIKit

final class ValidatableFormView: UIView {
    private let contentScrollView = ScrollableStackView(views: [], spacing: Spacing.medium)
    private let requiredFields: [UITextField]
    
    init(requiredFields: [UITextField]) {
        self.requiredFields = requiredFields
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addRow(labelText: String, inputView: UIView) {
        let formRow = StackViewFactory.createVerticalFieldGroup(
            labelText: labelText,
            inputView: inputView
        )
        contentScrollView.addArrangedSubview(formRow)
    }
    
    func applyValidationResults(_ results: [ValidatedField]) {
        for result in results {
            guard let textField = requiredFields.first(where: {$0.accessibilityIdentifier == result.fieldIdentifier}) else {
                continue
            }
            applyValidationStyle(textField, isValid: result.isValid)
        }
    }
    
    func applyValidationStyle(_ textField: UITextField, isValid: Bool) {
        if isValid {
            textField.layer.borderColor = Colors.border.cgColor
            textField.layer.borderWidth = BorderWidth.thin
        } else {
            textField.layer.borderColor = Colors.invalidBorder.cgColor
            textField.layer.borderWidth = BorderWidth.normal
        }
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentScrollView)
        
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Spacing.medium),
            contentScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.extraLarge),
            contentScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.extraLarge),
            contentScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.medium)
        ])
    }
}
