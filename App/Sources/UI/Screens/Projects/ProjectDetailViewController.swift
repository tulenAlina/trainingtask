import UIKit

final class ProjectDetailViewController: BaseViewController {
    weak var updateDelegate: ProjectUpdateDelegate?
    weak var deleteDelegate: ProjectDeleteDelegate?
    
    private let server: Server
    private let settings: SettingsManager
    private let indexPath: IndexPath
    private var project: Project
    
    private var nameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var openTasksButton = UIButton()
    private var deleteButton = UIButton()
    
    init(indexPath: IndexPath, project: Project, server: Server, settings: SettingsManager, updateDelegate: ProjectUpdateDelegate, deleteDelegate: ProjectDeleteDelegate) {
        self.indexPath = indexPath
        self.project = project
        self.server = server
        self.settings = settings
        self.updateDelegate = updateDelegate
        self.deleteDelegate = deleteDelegate
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
        setupNavigationTitle(Localized.projectDetails)
        setupLabels()
        setupButtons()
        setupConstraints()
        setupRightBarButton(title: Localized.edit, action: #selector(didTapChangeButton))
    }
    
    private func setupLabels() {
        updateLabels()
        
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.numberOfLines = 5
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.numberOfLines = 20
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
    }
    
    private func setupButtons() {
        openTasksButton.setTitle(Localized.openTasks, for: .normal)
        openTasksButton.setTitleColor(.black, for: .normal)
        openTasksButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        openTasksButton.layer.borderWidth = 0.5
        openTasksButton.layer.borderColor = UIColor.darkGray.cgColor
        openTasksButton.layer.cornerRadius = 12
        openTasksButton.translatesAutoresizingMaskIntoConstraints = false
        openTasksButton.addTarget(self, action: #selector(didTapOpenTasksButton), for: .touchUpInside)
        
        deleteButton.setTitle(Localized.delete, for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        deleteButton.layer.borderWidth = 0.5
        deleteButton.layer.borderColor = UIColor.red.cgColor
        deleteButton.layer.cornerRadius = 12
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        
        view.addSubview(openTasksButton)
        view.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 40),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            openTasksButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            openTasksButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openTasksButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            openTasksButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            deleteButton.topAnchor.constraint(equalTo: openTasksButton.bottomAnchor, constant: 10),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func updateLabels() {
        nameLabel.text = project.projectName
        descriptionLabel.text = project.description
    }
        
    @objc private func didTapChangeButton() {
        let editViewController = EditProjectViewController(project: project, server: server, updateDelegate: self)
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    @objc private func didTapDeleteButton() {
        deleteDelegate?.didDeleteProject(project, at: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapOpenTasksButton() {
        let tasksViewConttroller = TasksViewController(project: project, server: server, settings: settings)
        navigationController?.pushViewController(tasksViewConttroller, animated: true)
    }
}

extension ProjectDetailViewController: ProjectUpdateDelegate {
    func didUpdateProject(_ project: Project) {
        self.project = project
        self.updateDelegate?.didUpdateProject(project)
        updateLabels()
    }
}
