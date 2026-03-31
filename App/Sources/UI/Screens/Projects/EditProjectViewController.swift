import UIKit

final class EditProjectViewController: UIViewController {
    weak var delegate: ProjectsViewControllerDelegate?
    var saveButton = UIBarButtonItem()
    
    private let server: Server
    private var project: Project?
    
    private var nameTextField = UIFactory.createTextField(placeholder: Localized.projectNamePlaceholder)
    private var descriptionTextField = UIFactory.createTextField(placeholder: Localized.projectDescriptionPlaceholder)
    
    private let nameLabel = UIFactory.createLabel(text: Localized.nameLabel)
    private let descriptionLabel = UIFactory.createLabel(text: Localized.descriptionLabel)
    
    private var loadingIndicator = UIActivityIndicatorView(style: .large)
    
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
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = (project != nil) ? Localized.editProject : Localized.addProject
        setupTextFieldsAndLabels()
        setupConstraints()
        setupNavigationBar()
        setupLoadingIndicator()
    }
    
    private func setupTextFieldsAndLabels() {
        if let project {
            nameTextField.text = "\(project.projectName)"
            descriptionTextField.text = "\(project.description)"
        }
        nameTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        
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
    
    private func setupNavigationBar() {
        saveButton.title = Localized.save
        saveButton.style = .done
        saveButton.target = self
        saveButton.action = #selector(saveProject)
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
    }
    
    private func startLoading() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        saveButton.isEnabled = false
    }
    
    private func stopLoading() {
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
        saveButton.isEnabled = true
    }
    
    private func prepareUpdateData(_ project: Project) -> Project {
        var updatedProject = project
        updatedProject.projectName = nameTextField.text?.trimmed ?? ""
        updatedProject.description = descriptionTextField.text?.trimmed ?? ""
        return updatedProject
    }
    
    private func prepareCreateData() -> Project {
        return Project(
            projectName: nameTextField.text?.trimmed ?? "",
            description: descriptionTextField.text?.trimmed ?? ""
        )
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
    
    private func performSave() async throws -> Project {
        if let project {
            let updatedProject = prepareUpdateData(project)
            return try await server.updateProject(updatedProject)
        } else {
            let createdProject = prepareCreateData()
            return try await server.createProject(createdProject)
            
        }
    }
    
    @objc private func saveProject() {
        startLoading()
        Task {
            do {
                let savedProject = try await performSave()
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
    
    @objc private func updateSaveButtonState() {
        saveButton.isEnabled = isFormValid
    }
}

extension EditProjectViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditProjectViewController: FormValidatable {
    var isFieldsChanged: Bool {
        guard let project = project else { return true }
            let nameChanged = (nameTextField.text?.trimmed ?? "") != project.projectName.trimmed
            let descriptionChanged = (descriptionTextField.text?.trimmed ?? "") != project.description.trimmed
            return nameChanged || descriptionChanged
    }
    
    var isFormFilled: Bool {
        let isNameFilled = !(nameTextField.text?.trimmed.isBlank ?? true)
        let isDescriptionFilled = !(descriptionTextField.text?.trimmed.isBlank ?? true)
        return isNameFilled && isDescriptionFilled
    }
}
