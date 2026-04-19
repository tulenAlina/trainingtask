import UIKit

final class ProjectDetailViewController: BaseViewController {
    var onUpdate: ((Project) -> Void)
    var onDelete: ((IndexPath) -> Void)
    
    private let server: Server
    private let settings: SettingsManager
    private let indexPath: IndexPath
    private var project: Project
    
    private let nameLabel = UIFactory.createTitleLargeLabel()
    private let descriptionRow = InfoRowView(title: Localized.descriptionLabel)
    private var openTasksButton = UIFactory.createSecondaryButton(text: Localized.openTasks)
    private var deleteButton = UIFactory.createDeleteButton()
    
    private lazy var buttonsStackView = UIFactory.createVerticalStackView(views: [openTasksButton, deleteButton], spacing: 10)
    private lazy var contentScrollView = ScrollableStackView(views: [nameLabel, descriptionRow, buttonsStackView], spacing: 30)
    
    init(indexPath: IndexPath, project: Project, server: Server, settings: SettingsManager, onUpdate: @escaping ((Project) -> Void), onDelete: @escaping ((IndexPath) -> Void)) {
        self.indexPath = indexPath
        self.project = project
        self.server = server
        self.settings = settings
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        setupNavigationBar(navigationTitle: Localized.projectDetails, rightButtonTitle: Localized.edit, rightButtonAction: #selector(actionChangeProject))
        setupContentView()
        setupButtons()
        updateLabels()
    }

    private func setupContentView() {
        view.addSubview(contentScrollView)
                
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }
    
    private func setupButtons() {
        openTasksButton.addTarget(self, action: #selector(actionOpenTasks), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(actionDeleteProject), for: .touchUpInside)

        NSLayoutConstraint.activate([
            openTasksButton.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            openTasksButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            openTasksButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            deleteButton.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func updateLabels() {
        nameLabel.text = project.projectName
        descriptionRow.value = project.description
    }
        
    @objc private func actionChangeProject() {
        let editViewController = EditProjectViewController(project: project, server: server, action: .update({[weak self] project in
            self?.project = project
            self?.onUpdate(project)
            self?.updateLabels()
        }))
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    @objc private func actionDeleteProject() {
        onDelete(indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func actionOpenTasks() {
        let tasksViewConttroller = TasksViewController(project: project, server: server, settings: settings)
        navigationController?.pushViewController(tasksViewConttroller, animated: true)
    }
}
