import UIKit

protocol MainMenuRouterInputProtocol {
    func openProjects()
    func openTasks()
    func openEmployees()
    func openSettings()
}

final class MainMenuRouter: MainMenuRouterInputProtocol {
    weak var viewController: UIViewController?

    func openProjects() {
        let projectsModule = ProjectsModule.build()
        viewController?.navigationController?.pushViewController(projectsModule.view, animated: true)

    }
    
    func openTasks() {
        let tasksModule = TasksModule.build()
        viewController?.navigationController?.pushViewController(tasksModule.view, animated: true)
    }
    
    func openEmployees() {
        let employeesModule = EmployeesModule.build()
        viewController?.navigationController?.pushViewController(employeesModule.view, animated: true)
    }
    
    func openSettings() {
        let settingsModule = SettingsModule.build()
        viewController?.navigationController?.pushViewController(settingsModule.view, animated: true)
    }
}
