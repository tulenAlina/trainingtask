import UIKit

final class EditProjectViewController: BaseFormViewController {
    weak var delegate: ProjectsViewControllerDelegate?
    
    private let server: Server
    private var project: Project?
    
    private let nameLabel = UIFactory.createLabel(text: Localized.nameLabel)
    private let descriptionLabel = UIFactory.createLabel(text: Localized.descriptionLabel)
    
    private var nameTextField = UIFactory.createTextField(placeholder: Localized.projectNamePlaceholder)
    private var descriptionTextField = UIFactory.createTextField(placeholder: Localized.projectDescriptionPlaceholder)
    
    init(project: Project? = nil, server: Server) {
        self.project = project
        self.server = server
        super.init(nibName: nil, bundle: nil)
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
        setupTextFieldsAndLabels()
        setupConstraints()
        addSaveButton(action: #selector(saveProject))
    }
    
    private func setupTextFieldsAndLabels() {
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
    
    private func newProjectFromForm() -> Project {
        return Project(
            projectName: nameTextField.text?.trimmed ?? "",
            description: descriptionTextField.text?.trimmed ?? ""
        )
    }

    private func fetchSavedProject() async throws -> Project {
        if let project {
            let updatedProject = updatedProject(project)
            return try await server.updateProject(updatedProject)
        } else {
            let createdProject = newProjectFromForm()
            return try await server.createProject(createdProject)
            
        }
    }
    
    private func handleSuccess(savedProject: Project) {
        if project != nil {
            delegate?.didUpdateProject(savedProject)
        } else {
            delegate?.didAddProject(savedProject)
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
    
    @objc private func saveProject() {
        guard validateFields() else { return }
        guard isFieldsChanged() else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        startLoading()
        Task {
            do {
                let savedProject = try await fetchSavedProject()
                DispatchQueue.main.async {
                    self.handleSuccess(savedProject: savedProject)
                }
            } catch {
                await MainActor.run {
                    self.showAlert(Localized.saveFailed)
                    stopLoading()
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
