import UIKit

final class MainMenuViewController: UIViewController {
    
    private let settings: SettingsManager
    private let server: Server
    private let menuItems = [Localized.projects, Localized.tasks, Localized.employees, Localized.settings]
    
    private lazy var buttons: [UIButton] = {
        menuItems.map { title in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .lightGray
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
            return button
        }
    }()
            
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
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
        view.addSubview(stackView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: CGFloat(buttons.count * 60))
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
