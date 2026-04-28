import UIKit

enum EditProjectFieldType {
    case name
    case description
}

protocol EditProjectViewInputProtocol: AnyObject {
    var requiredFields: [UITextField] { get }
    
    func setupNavigationBar(title: String)
    func setProjectFields(name: String, description: String)
    func applyValidationResults(_ fieldsValidity: [Bool])
    func updateValidationStyle(textFieldType: EditProjectFieldType, isValid: Bool)
    func startLoading()
    func stopLoading()
    func showAlert(_ message: String)
}

protocol EditProjectViewOutputProtocol {
    func viewDidLoad()
    func didTapSaveButton(name: String, description: String)
    func textFieldDidChange(textFieldType: EditProjectFieldType, text: String?)
}

final class EditProjectViewController: BaseViewController, EditProjectViewInputProtocol {
    var output: EditProjectViewOutputProtocol
    
    var requiredFields: [UITextField] {
        [nameTextField, descriptionTextField]
    }
    
    private var nameTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.projectNamePlaceholder)
    private var descriptionTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.projectDescriptionPlaceholder)
    
    private let projectEditView = ValidatableFormView()
    
    init(presenter: EditProjectViewOutputProtocol) {
        output = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        output.viewDidLoad()
    }

    func setupNavigationBar(title: String) {
        super.setupNavigationBar(navigationTitle: title, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveProject))
    }
    
    func setProjectFields(name: String, description: String) {
        nameTextField.text = name
        descriptionTextField.text = description
    }
    
    func applyValidationResults(_ fieldsValidity: [Bool]) {
        var result: [ValidatedField] = []
        for i in 0..<requiredFields.count {
            result.append(ValidatedField(textField: requiredFields[i], isValid: fieldsValidity[i]))
        }
        projectEditView.applyValidationResults(result)
    }
    
    func updateValidationStyle(textFieldType: EditProjectFieldType, isValid: Bool) {
        let textField: UITextField?
            switch textFieldType {
            case .name:
                textField = nameTextField
            case .description:
                textField = descriptionTextField
            }
        guard let textField else { return }
        projectEditView.applyValidationStyle(textField, isValid: isValid)
    }
}

// MARK: - UITextFieldDelegate
extension EditProjectViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - Private
private extension EditProjectViewController {
    func fieldType(for textField: UITextField) -> EditProjectFieldType? {
        switch textField {
        case nameTextField:
            return .name
        case descriptionTextField:
            return .description
        default:
            return nil
        }
    }
    
    func setupView() {
        setupEditView()
        setupTextFields()
        setupActions()
    }
    
    func setupEditView() {
        projectEditView.addRow(labelText: Localized.nameLabel, inputView: nameTextField)
        projectEditView.addRow(labelText: Localized.descriptionLabel, inputView: descriptionTextField)
        
        view.addSubview(projectEditView)
        
        NSLayoutConstraint.activate([
            projectEditView.topAnchor.constraint(equalTo: view.topAnchor),
            projectEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            projectEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            projectEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupTextFields() {
        nameTextField.delegate = self
        descriptionTextField.delegate = self
    }
    
    func setupActions() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func actionSaveProject() {
        let name = nameTextField.text.unwrappedOrEmpty.trimmed
        let description = descriptionTextField.text.unwrappedOrEmpty.trimmed
        
        output.didTapSaveButton(
            name: name,
            description: description
        )
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let fieldType = fieldType(for: textField) else {
            return
        }
        output.textFieldDidChange(textFieldType: fieldType, text: textField.text)
    }
}
