import UIKit

final class EditProjectViewController: BaseViewController {
    private let server: Server
    private var project: Project?
    private let action: EditProjectAction
    
    private var nameTextField = UIFactory.createDefaultTextField(placeholder: Localized.projectNamePlaceholder)
    private var descriptionTextField = UIFactory.createDefaultTextField(placeholder: Localized.projectDescriptionPlaceholder)
    
    private let projectEditView = EditView()
    
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
        setupUI()
    }
    
    private func setupUI() {
        let title = (project != nil) ? Localized.editProject : Localized.addProject
        setupNavigationBar(navigationTitle: title, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveProject))
        
        setupTextFields()
        setupEditView()
    }
    
    private func setupTextFields() {
        if let project {
            nameTextField.text = "\(project.projectName)"
            descriptionTextField.text = "\(project.description)"
        }
        nameTextField.addTarget(projectEditView, action: #selector(projectEditView.textFieldDidChange), for: .editingChanged)
        descriptionTextField.addTarget(projectEditView, action: #selector(projectEditView.textFieldDidChange), for: .editingChanged)
        
        nameTextField.delegate = self
        descriptionTextField.delegate = self
    }
    
    private func setupEditView() {
        view.addSubview(projectEditView)
        projectEditView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            projectEditView.topAnchor.constraint(equalTo: view.topAnchor),
            projectEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            projectEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            projectEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let formRows: [(String, UIView)] = [
            (labelText: Localized.nameLabel, inputView: nameTextField),
            (labelText: Localized.descriptionLabel, inputView: descriptionTextField)
        ]
        
        projectEditView.setupForm(rows: formRows)
    }

    private func isFieldsChanged() -> Bool {
        guard let project else {
            return true
        }
        let isNameChanged = (nameTextField.text.unwrappedOrEmpty.trimmed) != project.projectName.trimmed
        let isDescriptionChanged = (descriptionTextField.text.unwrappedOrEmpty.trimmed) != project.description.trimmed
        
        return isNameChanged || isDescriptionChanged
    }
    
    private func validateFields(nameString: String, descriptionString: String) -> Bool {
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
    
    private func applyValidationResults(_ fieldsValidity: [Bool]) {
        var result: [(UITextField, Bool)] = []
        for i in 0..<requiredFields.count {
            result.append((requiredFields[i], fieldsValidity[i]))
        }
        projectEditView.applyValidationResults(result)
    }
    
    private func updatedProject(_ project: Project) -> Project {
        let newProjectName = nameTextField.text.unwrappedOrEmpty.trimmed
        let newDescription = descriptionTextField.text.unwrappedOrEmpty.trimmed
        
        let updatedProject = Project(
            id: project.id,
            projectName: newProjectName,
            description: newDescription,
            tasks: project.tasks,
            createdAt: project.createdAt
        )
        
        return updatedProject
    }
    
    private func createProject() -> Project {
        return Project(
            projectName: nameTextField.text.unwrappedOrEmpty.trimmed,
            description: descriptionTextField.text.unwrappedOrEmpty.trimmed
        )
    }

    private func saveProject() async throws -> Project {
        if let project {
            let updatedProject = updatedProject(project)
            return try await server.updateProject(updatedProject)
        } else {
            let createdProject = createProject()
            return try await server.createProject(createdProject)
        }
    }
    
    @objc private func actionSaveProject() {
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
}

extension EditProjectViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
