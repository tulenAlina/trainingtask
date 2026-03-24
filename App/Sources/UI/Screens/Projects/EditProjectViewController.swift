import UIKit

final class EditProjectViewController: UIViewController {
    weak var delegate: ProjectsViewControllerDelegate?
    
    private var project: Project? = nil
    private var projectNameTF: UITextField!
    private var projectDescriptionTF: UITextField!
    private var saveButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ project: Project) {
        self.project = project
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = (project != nil) ? "Редактирование" : "Создание"
        
        saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveProject))
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        
        setupTextFields()
        
        view.addSubview(projectNameTF)
        view.addSubview(projectDescriptionTF)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            projectNameTF.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            projectNameTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            projectNameTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            projectDescriptionTF.topAnchor.constraint(equalTo: projectNameTF.bottomAnchor, constant: 30),
            projectDescriptionTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            projectDescriptionTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        projectNameTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        projectDescriptionTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
    }
    
    private func setupTextFields() {
        var isEdit = false
        if let project {
            isEdit = true
            projectNameTF = UITextField.create(text: "\(project.projectName)", placeholder: "Введите название", isEdit: isEdit)
            projectDescriptionTF = UITextField.create(text: "\(project.description)", placeholder: "Введите описание", isEdit: isEdit)
        } else {
            projectNameTF = UITextField.create(placeholder: "Введите название", isEdit: isEdit)
            projectDescriptionTF = UITextField.create(placeholder: "Введите описание", isEdit: isEdit)
        }
    }
    
    @objc private func saveProject() {
        let server = ServerManager.shared.currentServer
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        saveButton.isEnabled = false
        Task {
            do {
                if let project {
                    var newProject = project
                    newProject.projectName = projectNameTF.text?.trimmed ?? ""
                    newProject.description = projectDescriptionTF.text?.trimmed ?? ""
                    let savedProject = try await server.updateProject(newProject)
                    DispatchQueue.main.async {
                        self.delegate?.didUpdateProject(savedProject)
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.saveButton.isEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    let newProject = Project(
                        projectName: projectNameTF.text?.trimmed ?? "",
                        description: projectDescriptionTF.text?.trimmed ?? ""
                    )
                    let savedProject = try await server.createProject(newProject)
                    DispatchQueue.main.async {
                        self.delegate?.didAddProject(savedProject)
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.saveButton.isEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                    
                } catch {
                    await MainActor.run {
                        self.showAlert("Не удалось сохранить проект")
                    }
                }
            }
    }
    
    @objc private func updateSaveButtonState() {
        var isFieldsMatched = false
        if let project {
            isFieldsMatched = (projectNameTF.text?.trimmed ?? "" == project.projectName.trimmed) && (projectDescriptionTF.text?.trimmed ?? "" == project.description.trimmed)
        }
        let isNameFilled = !(projectNameTF.text?.trimmed.isBlank ?? true)
        let isDescriptionFilled = !(projectDescriptionTF.text?.trimmed.isBlank ?? true)
        
        saveButton.isEnabled = !isFieldsMatched && isNameFilled && isDescriptionFilled
    }
}
