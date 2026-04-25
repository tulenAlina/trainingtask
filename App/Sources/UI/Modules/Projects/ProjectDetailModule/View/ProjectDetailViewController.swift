import UIKit

protocol ProjectDetailViewInputProtocol: AnyObject {
    func configureLabels(name: String, description: String)
}

protocol ProjectDetailViewOutputProtocol {
    func viewDidLoad()
    func didTapChangeButton()
    func didTapOpenTasksButton()
    func didTapDeleteButton()
}

final class ProjectDetailViewController: BaseViewController, ProjectDetailViewInputProtocol {
    var output: ProjectDetailViewOutputProtocol
    
    private let nameLabel = LabelFactory.createTitleLargeLabel()
    private let descriptionRow = InfoRowView(title: Localized.descriptionLabel)
    private var openTasksButton = ButtonFactory.createSecondaryButton(text: Localized.openTasks)
    private var deleteButton = ButtonFactory.createDeleteButton()
    
    private lazy var buttonsStackView = StackViewFactory.createVerticalStackView(views: [openTasksButton, deleteButton], spacing: 10)
    private lazy var contentScrollView = ScrollableStackView(views: [nameLabel, descriptionRow, buttonsStackView], spacing: 30)
    
    init(presenter: ProjectDetailViewOutputProtocol) {
        output = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        output.viewDidLoad()
    }
    
    func configureLabels(name: String, description: String) {
        nameLabel.text = name
        descriptionRow.configure(value: description)
    }
}

// MARK: - Private

private extension ProjectDetailViewController {
    func setupView() {
        setupNavigationBar(navigationTitle: Localized.projectDetails, rightButtonTitle: Localized.edit, rightButtonAction: #selector(actionChangeProject))
        setupContentView()
        setupButtons()
        setupActions()
    }
    
    func setupContentView() {
        view.addSubview(contentScrollView)
                
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }
    
    func setupButtons() {
        NSLayoutConstraint.activate([
            openTasksButton.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            openTasksButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            openTasksButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            deleteButton.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    func setupActions() {
        openTasksButton.addTarget(self, action: #selector(actionOpenTasks), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(actionDeleteProject), for: .touchUpInside)
    }
    
    @objc func actionOpenTasks() {
        output.didTapOpenTasksButton()
    }
    
    @objc func actionDeleteProject() {
        output.didTapDeleteButton()
    }
    
    @objc func actionChangeProject() {
        output.didTapChangeButton()
    }
}
