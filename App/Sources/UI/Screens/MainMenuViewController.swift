import UIKit

enum MenuItem: Int, CaseIterable {
    case projects
    case tasks
    case employees
    case settings
    
    var title: String {
        switch self {
        case .projects: return Localized.projects
        case .tasks: return Localized.tasks
        case .employees: return Localized.employees
        case .settings: return Localized.settings
        }
    }
    
    func makeViewController() -> UIViewController {
        switch self {
        case .projects:
            return ProjectsViewController()
        case .tasks:
            return TasksViewController()
        case .employees:
            return EmployeesViewController()
        case .settings:
            return SettingsViewController()
        }
    }
}

final class MainMenuViewController: UIViewController {
    private let settings: SettingsManager
    private let server: Server
    private let menuItems = MenuItem.allCases
    
    private lazy var buttons: [UIButton] = ButtonFactory.createMenuButtons(from: menuItems, target: self, action: #selector(actionButtonTapped))
    private lazy var contentScrollView = ScrollableStackView(views: buttons, spacing: 15)
    
    init(server: Server, settings: SettingsManager) {
        self.settings = settings
        self.server = server
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
        view.backgroundColor = .white
        title = Localized.mainMenu
        setupContentView()
        setupButtons()
    }
    
    private func setupContentView() {
        view.addSubview(contentScrollView)
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            contentScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }
    
    private func setupButtons() {
        buttons.forEach { button in
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05)
            ])
        }
    }
    
    @objc private func actionButtonTapped(_ sender: UIButton) {
        guard let item = MenuItem(rawValue: sender.tag) else {
            return
        }
        let viewController = item.makeViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
