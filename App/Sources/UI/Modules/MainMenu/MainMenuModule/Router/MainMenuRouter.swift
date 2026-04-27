import UIKit

protocol MainMenuRouterInputProtocol {
    func pushProjectsScreen()
    func pushTasksScreen()
    func pushEmployeesScreen()
    func pushSettingsScreen()
}

final class MainMenuRouter: MainMenuRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushProjectsScreen() {
        let projectsModule = ProjectsModule.build()
        viewController?.navigationController?.pushViewController(projectsModule.view, animated: true)

    }
    
    func pushTasksScreen() {
        let tasksModule = TasksModule.build()
        viewController?.navigationController?.pushViewController(tasksModule.view, animated: true)
    }
    
    func pushEmployeesScreen() {
        let employeesModule = EmployeesModule.build()
        viewController?.navigationController?.pushViewController(employeesModule.view, animated: true)
    }
    
    func pushSettingsScreen() {
        let settingsModule = SettingsModule.build()
        viewController?.navigationController?.pushViewController(settingsModule.view, animated: true)
    }
}
