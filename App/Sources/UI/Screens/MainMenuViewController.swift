import UIKit

final class MainMenuViewController: UIViewController {
    
    private lazy var projectButton = self.createButton("Проекты")
    private lazy var taskButton = self.createButton("Задачи")
    private lazy var employeeButton = self.createButton("Сотрудники")
    private lazy var settingsButton = self.createButton("Настройки")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Главное меню"
        
        view.addSubview(projectButton)
        view.addSubview(taskButton)
        view.addSubview(employeeButton)
        view.addSubview(settingsButton)
        NSLayoutConstraint.activate([
            projectButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            projectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            projectButton.widthAnchor.constraint(equalToConstant: 200),
            projectButton.heightAnchor.constraint(equalToConstant: 50),
                    
            taskButton.topAnchor.constraint(equalTo: projectButton.bottomAnchor, constant: 10),
            taskButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskButton.widthAnchor.constraint(equalToConstant: 200),
            taskButton.heightAnchor.constraint(equalToConstant: 50),
            
            employeeButton.topAnchor.constraint(equalTo: taskButton.bottomAnchor, constant: 10),
            employeeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            employeeButton.widthAnchor.constraint(equalToConstant: 200),
            employeeButton.heightAnchor.constraint(equalToConstant: 50),
            
            settingsButton.topAnchor.constraint(equalTo: employeeButton.bottomAnchor, constant: 10),
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            settingsButton.widthAnchor.constraint(equalToConstant: 200),
            settingsButton.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
    
    private func createButton(_ title: String) -> UIButton {
        let btn = UIButton()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .lightGray
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender {
        case projectButton:
            navigationController?.pushViewController(ProjectsViewController(), animated: true)
        case taskButton:
            navigationController?.pushViewController(TasksViewController(), animated: true)
        case employeeButton:
            navigationController?.pushViewController(EmployeesViewController(), animated: true)
        case settingsButton:
            navigationController?.pushViewController(SettingsViewController(), animated: true)
        default:
            break
            
            
        }
    }
}
