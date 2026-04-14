import UIKit

final class EditProjectViewController: BaseFormViewController {
    private let server: Server
    private var project: Project?
    private let action: EditProjectAction
    
    private var nameTextField = UIFactory.createDefaultTextField(placeholder: Localized.projectNamePlaceholder)
    private var descriptionTextField = UIFactory.createDefaultTextField(placeholder: Localized.projectDescriptionPlaceholder)
    
    init(project: Project? = nil, server: Server, action: EditProjectAction) {
        self.project = project
        self.server = server
        self.action = action
        super.init(nibName: nil, bundle: nil)
        requiredFields = [nameTextField, descriptionTextField]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func isFieldsChanged() -> Bool {
        guard let project = project else { return true }
        let isNameChanged = (nameTextField.text.unwrappedOrEmpty.trimmed) != project.projectName.trimmed
        let isDescriptionChanged = (descriptionTextField.text.unwrappedOrEmpty.trimmed) != project.description.trimmed
        return isNameChanged || isDescriptionChanged
    }
    
    private func setupUI() {
        let title = (project != nil) ? Localized.editProject : Localized.addProject
        setupNavigationBar(navigationTitle: title, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveProject))
        
        setupTextFields()
        setupFormRows()
        setupForm()
    }
    
    private func setupTextFields() {
        if let project {
            nameTextField.text = "\(project.projectName)"
            descriptionTextField.text = "\(project.description)"
        }
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        nameTextField.delegate = self
        descriptionTextField.delegate = self
    }
    
    private func setupFormRows() {
        let nameRow = UIFactory.createVerticalFieldGroup(labelText: Localized.nameLabel, inputView: nameTextField)
        let descriptionRow = UIFactory.createVerticalFieldGroup(labelText: Localized.descriptionLabel, inputView: descriptionTextField)
        
        [nameRow, descriptionRow].forEach { row in
            stackView.addArrangedSubview(row)
        }
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
        guard validateFields() else { return }
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
