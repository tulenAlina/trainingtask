import UIKit

final class MainMenuViewController: UIViewController {
    
    private let settings: SettingsManager
    private let server: Server
    private let menuItems = [Localized.projects, Localized.tasks, Localized.employees, Localized.settings]
    
    private lazy var buttons: [UIButton] = {
        menuItems.map { title in
            let button = UIFactory.createDefaultButton(text: title)
            button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
            return button
        }
    }()
            
    private lazy var сontentScrollView = ScrollableStackView(views: buttons, spacing: 15)
    
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
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = Localized.mainMenu
        setupContentView()
    }
    
    private func setupContentView() {
        view.addSubview(сontentScrollView)
        
        for button in buttons {
            button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05).isActive = true
        }
        
        NSLayoutConstraint.activate([
            сontentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            сontentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            сontentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            сontentScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }
    
    @objc private func actionButtonTapped(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        
        switch title {
        case Localized.projects:
            let projectsViewController = ProjectsViewController(server: server, settings: settings)
            navigationController?.pushViewController(projectsViewController, animated: true)
        case Localized.tasks:
            let tasksViewController = TasksViewController(server: server, settings: settings)
            navigationController?.pushViewController(tasksViewController, animated: true)
        case Localized.employees:
            let employeesViewController = EmployeesViewController(server: server, settings: settings)
            navigationController?.pushViewController(employeesViewController, animated: true)
        case Localized.settings:
            let settingsViewController = SettingsViewController(settings: settings)
            navigationController?.pushViewController(settingsViewController, animated: true)
        default:
            break
        }
    }
}
