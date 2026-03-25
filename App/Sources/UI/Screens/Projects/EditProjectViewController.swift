import UIKit

final class EditProjectViewController: UIViewController {
    weak var delegate: ProjectsViewControllerDelegate?
    var saveButton: UIBarButtonItem!
    
    private let server = ServerManager.shared.currentServer
    private var project: Project?
    private var nameTextField: UITextField!
    private var descriptionTextField: UITextField!
    private var cancelButton: UIBarButtonItem!
    private var loadingIndicator: UIActivityIndicatorView!
    
    init(_ project: Project? = nil) {
        self.project = project
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
        title = (project != nil) ? "Редактирование" : "Создание"
        setupTextFields()
        setupNavigationBar()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30),
            descriptionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationBar() {
        saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveProject))
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
    }
    
    private func setupTextFields() {
        var isEdit = false
        if let project {
            isEdit = true
            nameTextField = UITextField.create(text: "\(project.projectName)", placeholder: "Введите название", isEdit: isEdit)
            descriptionTextField = UITextField.create(text: "\(project.description)", placeholder: "Введите описание", isEdit: isEdit)
        } else {
            nameTextField = UITextField.create(placeholder: "Введите название", isEdit: isEdit)
            descriptionTextField = UITextField.create(placeholder: "Введите описание", isEdit: isEdit)
        }
        nameTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        
        view.addSubview(nameTextField)
        view.addSubview(descriptionTextField)
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
    
    private func prepareUpdateData() -> Project {
        var updatedProject = project!
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
        if project != nil {
            let updatedProject = prepareUpdateData()
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
                    self.showAlert("Не удалось сохранить проект")
                }
            }
        }
    }
    
    @objc private func updateSaveButtonState() {
        saveButton.isEnabled = isFormValid
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
