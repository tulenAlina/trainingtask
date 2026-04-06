import UIKit

final class EditProjectViewController: BaseFormViewController {
    weak var updateDelegate: ProjectUpdateDelegate?
    weak var createDelegate: ProjectCreateDelegate?
    
    private let server: Server
    private var project: Project?
    
    private let nameLabel = UIFactory.createLabel(text: Localized.nameLabel)
    private let descriptionLabel = UIFactory.createLabel(text: Localized.descriptionLabel)
    
    private var nameTextField = UIFactory.createTextField(placeholder: Localized.projectNamePlaceholder)
    private var descriptionTextField = UIFactory.createTextField(placeholder: Localized.projectDescriptionPlaceholder)
    
    private init(project: Project? = nil, server: Server) {
        self.project = project
        self.server = server
        super.init(nibName: nil, bundle: nil)
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
        setupRequiredFields()
        setupUI()
    }
    
    private func setupRequiredFields() {
        requiredFields = [nameTextField, descriptionTextField]
    }
    
    private func setupUI() {
        setupNavigationTitle((project != nil) ? Localized.editProject : Localized.addProject)
        setupInputFields()
        setupConstraints()
        addSaveButton(action: #selector(didTapSaveButton))
    }
    
    private func setupInputFields() {
        if let project {
            nameTextField.text = "\(project.projectName)"
            descriptionTextField.text = "\(project.description)"
        }
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        
        view.addSubview(nameTextField)
        view.addSubview(nameLabel)
        view.addSubview(descriptionTextField)
        view.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            descriptionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func updatedProject(_ project: Project) -> Project {
        var updatedProject = project
        updatedProject.projectName = nameTextField.text?.trimmed ?? ""
        updatedProject.description = descriptionTextField.text?.trimmed ?? ""
        return updatedProject
    }
    
    private func buildProject() -> Project {
        return Project(
            projectName: nameTextField.text?.trimmed ?? "",
            description: descriptionTextField.text?.trimmed ?? ""
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
    
    private func handleSuccess(savedProject: Project) {
        if project != nil {
            updateDelegate?.didUpdateProject(savedProject)
        } else {
            createDelegate?.didCreateProject(savedProject)
        }
        stopLoading()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func isFieldsChanged() -> Bool {
        guard let project = project else { return true }
        let nameChanged = (nameTextField.text?.trimmed ?? "") != project.projectName.trimmed
        let descriptionChanged = (descriptionTextField.text?.trimmed ?? "") != project.description.trimmed
        return nameChanged || descriptionChanged
    }
    
    @objc private func didTapSaveButton() {
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
                    handleSuccess(savedProject: savedProject)
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
