import UIKit

protocol ProjectDetailViewControllerDelegate: AnyObject {
    func didDeleteProject(_ project: Project, at indexPath: IndexPath)
}

final class ProjectDetailViewController: UIViewController {
    
    weak var delegate: ProjectsViewControllerDelegate?
    weak var deleteDelegate: ProjectDetailViewControllerDelegate?
    
    private let indexPath: IndexPath
    private let server: Server
    private let settings: SettingsManager
    private var project: Project
    private var nameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var openTasksButton = UIButton()
    private var deleteButton = UIButton()
    
    init(indexPath: IndexPath, project: Project, server: Server, settings: SettingsManager) {
        self.indexPath = indexPath
        self.project = project
        self.server = server
        self.settings = settings
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
        title = Localized.projectDetails
        setupLabels()
        setupButtons()
        setupConstraints()
        setupNavigationBar()
    }
    
    private func updateLabels() {
        nameLabel.text = "\(Localized.nameLabel) \(project.projectName)"
        descriptionLabel.text = "\(Localized.descriptionLabel) \(project.description)"
    }
    
    private func setupLabels() {
        updateLabels()
        
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupButtons() {
        openTasksButton.setTitle(Localized.openTasks, for: .normal)
        openTasksButton.setTitleColor(.black, for: .normal)
        openTasksButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        openTasksButton.layer.borderWidth = 0.5
        openTasksButton.layer.borderColor = UIColor.darkGray.cgColor
        openTasksButton.layer.cornerRadius = 12
        openTasksButton.translatesAutoresizingMaskIntoConstraints = false
        openTasksButton.addTarget(self, action: #selector(openTasksTapped), for: .touchUpInside)
        
        deleteButton.setTitle(Localized.delete, for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        deleteButton.layer.borderWidth = 0.5
        deleteButton.layer.borderColor = UIColor.red.cgColor
        deleteButton.layer.cornerRadius = 12
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        view.addSubview(openTasksButton)
        view.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
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
    
    private func setupNavigationBar() {
        let changeButton = UIBarButtonItem(title: Localized.edit, style: .plain, target: self, action: #selector(changeTapped))
        navigationItem.rightBarButtonItem = changeButton
    }
        
    @objc private func changeTapped() {
        let editViewController = EditProjectViewController(project: project, server: server)
        editViewController.delegate = self
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    @objc private func deleteTapped() {
        deleteDelegate?.didDeleteProject(project, at: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func openTasksTapped() {
        let tasksViewConttroller = TasksViewController(project: project, server: server, settings: settings)
        navigationController?.pushViewController(tasksViewConttroller, animated: true)
    }
}

extension ProjectDetailViewController: ProjectsViewControllerDelegate {
    func didUpdateProject(_ project: Project) {
        self.project = project
        self.delegate?.didUpdateProject(project)
        updateLabels()
    }
}
