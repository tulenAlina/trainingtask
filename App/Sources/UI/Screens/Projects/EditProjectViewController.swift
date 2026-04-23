import UIKit

final class EditProjectViewController: BaseViewController {
    private let server: Server
    private var project: Project?
    private let action: EditProjectAction
    
    private var nameTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.projectNamePlaceholder)
    private var descriptionTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.projectDescriptionPlaceholder)
    
    private let projectEditView = ValidatableFormView()
    
    private let requiredFields: [UITextField]
    
    init(project: Project? = nil, server: Server, action: EditProjectAction) {
        self.project = project
        self.server = server
        self.action = action
        requiredFields = [nameTextField, descriptionTextField]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

extension EditProjectViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

private extension EditProjectViewController {
    func setupView() {
        let title = (project != nil) ? Localized.editProject : Localized.addProject
        setupNavigationBar(navigationTitle: title, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveProject))
        setupTextFields()
        setupEditView()
        setupActions()
    }
    
    func setupTextFields() {
        if let project {
            nameTextField.text = "\(project.projectName)"
            descriptionTextField.text = "\(project.description)"
        }
        
        nameTextField.delegate = self
        descriptionTextField.delegate = self
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
    
    func setupActions() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    func isFieldsChanged() -> Bool {
        guard let project else {
            return true
        }
        
        let isNameChanged = (nameTextField.text.unwrappedOrEmpty.trimmed) != project.projectName.trimmed
        let isDescriptionChanged = (descriptionTextField.text.unwrappedOrEmpty.trimmed) != project.description.trimmed
        return isNameChanged || isDescriptionChanged
    }
    
    func validateFields(nameString: String, descriptionString: String) -> Bool {
        var fieldsValidity: [Bool] = []
        var isValid = true
        
        for text in [nameString, descriptionString]
        {
            if text.isBlank == true {
                fieldsValidity.append(false)
                isValid = false
            } else {
                fieldsValidity.append(true)
            }
        }
        applyValidationResults(fieldsValidity)
        return isValid
    }
    
    func applyValidationResults(_ fieldsValidity: [Bool]) {
        var result: [ValidatedField] = []
        for i in 0..<requiredFields.count {
            result.append(ValidatedField(textField: requiredFields[i], isValid: fieldsValidity[i]))
        }
        projectEditView.applyValidationResults(result)
    }
    
    func createProject(_ project: Project? = nil) -> Project {
        let newProjectName = nameTextField.text.unwrappedOrEmpty.trimmed
        let newDescription = descriptionTextField.text.unwrappedOrEmpty.trimmed
        if let project {
            return Project(
                id: project.id,
                projectName: newProjectName,
                description: newDescription,
                tasks: project.tasks,
                createdAt: project.createdAt
            )
        } else {
            return Project(
                projectName: nameTextField.text.unwrappedOrEmpty.trimmed,
                description: descriptionTextField.text.unwrappedOrEmpty.trimmed
            )
        }
    }

    func saveProject() async throws -> Project {
        if let project {
            let updatedProject = createProject(project)
            try await server.updateProject(updatedProject)
            return updatedProject
        } else {
            let createdProject = createProject()
            try await server.createProject(createdProject)
            return createdProject
        }
    }
    
    @objc func actionSaveProject() {
        guard validateFields(
            nameString: nameTextField.text.unwrappedOrEmpty.trimmed,
            descriptionString: descriptionTextField.text.unwrappedOrEmpty.trimmed,
        ) else {
            showAlert(Localized.emptyFields)
            return
        }
        guard isFieldsChanged() else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        startLoading()
        Task {
            do {
                let savedProject = try await saveProject()
                await MainActor.run {
                    switch self.action {
                    case .create(let onCreate):
                        onCreate(savedProject)
                    case .update(let onUpdate):
                        onUpdate(savedProject)
                    }
                    stopLoading()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    stopLoading()
                    showAlert(Localized.saveFailed)
                }
            }
        }
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        if sender.text?.isBlank == false {
            projectEditView.applyValidationStyle(sender, isValid: true)
        } else {
            projectEditView.applyValidationStyle(sender, isValid: false)
        }
    }
}
