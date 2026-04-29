import UIKit

protocol MainMenuRouterInputProtocol {
    func pushProjectsModule()
    func pushTasksModule()
    func pushEmployeesModule()
    func pushSettingsModule()
}

final class MainMenuRouter: MainMenuRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushProjectsModule() {
        let projectsModule = ProjectsModule.build()
        viewController?.navigationController?.pushViewController(projectsModule.view, animated: true)
        
    }
    
    func pushTasksModule() {
        let tasksModule = TasksModule.build()
        viewController?.navigationController?.pushViewController(tasksModule.view, animated: true)
    }
    
    func pushEmployeesModule() {
        let employeesModule = EmployeesModule.build()
        viewController?.navigationController?.pushViewController(employeesModule.view, animated: true)
    }
    
    func pushSettingsModule() {
        let settingsModule = SettingsModule.build()
        viewController?.navigationController?.pushViewController(settingsModule.view, animated: true)
    }
}
