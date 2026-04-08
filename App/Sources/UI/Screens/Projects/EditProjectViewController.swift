import UIKit

final class EditProjectViewController: BaseFormViewController {
    weak var updateDelegate: ProjectUpdateDelegate?
    weak var createDelegate: ProjectCreateDelegate?
    
    private let server: Server
    private var project: Project?
    
    private var nameTextField = UIFactory.createTextField(placeholder: Localized.projectNamePlaceholder)
    private var descriptionTextField = UIFactory.createTextField(placeholder: Localized.projectDescriptionPlaceholder)
    
    private init(project: Project? = nil, server: Server) {
        self.project = project
        self.server = server
        super.init(nibName: nil, bundle: nil)
        requiredFields = [nameTextField, descriptionTextField]
    }
    
    convenience init(project: Project? = nil, server: Server, updateDelegate: ProjectUpdateDelegate) {
        self.init(project: project, server: server)
        self.updateDelegate = updateDelegate
    }
    
    convenience init(project: Project? = nil, server: Server, createDelegate: ProjectCreateDelegate) {
        self.init(project: project, server: server)
        self.createDelegate = createDelegate
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
        let nameRow = UIFactory.createFormRow(labelText: Localized.nameLabel, inputView: nameTextField)
        let descriptionRow = UIFactory.createFormRow(labelText: Localized.descriptionLabel, inputView: descriptionTextField)
        
        [nameRow, descriptionRow].forEach { row in
            stackView.addArrangedSubview(row)
        }
    }
    
    private func updatedProject(_ project: Project) -> Project {
        let newProjectName = nameTextField.text.orEmpty.trimmed
        let newDescription = descriptionTextField.text.orEmpty.trimmed
        
        let updatedProject = Project(
            id: project.id,
            projectName: newProjectName,
            description: newDescription,
            tasks: project.tasks,
            createdAt: project.createdAt
        )
        
        return updatedProject
    }
    
    private func buildProject() -> Project {
        return Project(
            projectName: nameTextField.text.orEmpty.trimmed,
            description: descriptionTextField.text.orEmpty.trimmed
        )
    }

    private func saveProject() async throws -> Project {
        if let project {
            let updatedProject = updatedProject(project)
            return try await server.updateProject(updatedProject)
        } else {
            let createdProject = buildProject()
            return try await server.createProject(createdProject)
            
        }
    }
    
    override func isFieldsChanged() -> Bool {
        guard let project = project else { return true }
        let isNameChanged = (nameTextField.text.orEmpty.trimmed) != project.projectName.trimmed
        let isDescriptionChanged = (descriptionTextField.text.orEmpty.trimmed) != project.description.trimmed
        return isNameChanged || isDescriptionChanged
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
                    if project != nil {
                        updateDelegate?.didUpdateProject(savedProject)
                    } else {
                        createDelegate?.didCreateProject(savedProject)
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
