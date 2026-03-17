import UIKit

final class EditProjectViewController: UIViewController {
    private var project: ProjectEntity? = nil
    private var projectNameTF: UITextField!
    private var projectDescriptionTF: UITextField!
    private var saveButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    weak var delegate: ProjectsViewControllerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ project: ProjectEntity) {
        self.project = project
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createTextField(_ label: String, _ isEdit: Bool) -> UITextField{
        let textField = UITextField()
        if isEdit {
            textField.text = label
        } else {
            textField.placeholder = label
        }
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    private func setupTextFields() {
        var isEdit = false
        if let project {
            isEdit = true
            projectNameTF = createTextField("\(project.projectName)", isEdit)
            projectDescriptionTF = createTextField("\(project.description)", isEdit)
        } else {
            projectNameTF = createTextField("Введите название", isEdit)
            projectDescriptionTF = createTextField("Введите описание", isEdit)
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
                    newProject.projectName = projectNameTF.text ?? ""
                    newProject.description = projectDescriptionTF.text ?? ""
                    let savedProject = try await server.updateProject(newProject)
                    DispatchQueue.main.async {
                        self.delegate?.didUpdateProject(savedProject)
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.saveButton.isEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    let newProject = ProjectEntity(
                        projectName: projectNameTF.text ?? "",
                        description: projectDescriptionTF.text ?? ""
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
    
    @objc private func cancellView() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = (project != nil) ? "Редактирование проекта" : "Добавление проекта"
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveProject))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancellView))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        
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
    }
}
