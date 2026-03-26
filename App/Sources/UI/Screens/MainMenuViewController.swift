import UIKit

final class MainMenuViewController: UIViewController {
    
    private let menuItems = [MenuConstants.projects, MenuConstants.tasks, MenuConstants.employees, MenuConstants.settings]
    private lazy var buttons: [UIButton] = {
        menuItems.map { title in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .lightGray
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = Localized.Screen.mainMenu.localized
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
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let server = appDelegate.server
        let settings = appDelegate.settings
        
        switch title {
        case MenuConstants.projects:
            let projectsViewController = ProjectsViewController(server: server, settings: settings)
            navigationController?.pushViewController(projectsViewController, animated: true)
        case MenuConstants.tasks:
            let tasksViewController = TasksViewController(server: server, settings: settings)
            navigationController?.pushViewController(tasksViewController, animated: true)
        case MenuConstants.employees:
            let employeesViewController = EmployeesViewController(server: server, settings: settings)
            navigationController?.pushViewController(employeesViewController, animated: true)
        case MenuConstants.settings:
            let settingsViewController = SettingsViewController(settings: settings)
            navigationController?.pushViewController(settingsViewController, animated: true)
        default:
            break
        }
    }
}
