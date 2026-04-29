import UIKit

protocol MainMenuRouterInputProtocol {
    func pushModule(item: MenuItem)
}

final class MainMenuRouter: MainMenuRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushModule(item:  MenuItem) {
        let module: any Module
        switch item {
            
        case .projects:
            module = ProjectsModule.build()
        case .tasks:
            module = TasksModule.build()
        case .employees:
            module = EmployeesModule.build()
        case .settings:
            module = SettingsModule.build()
        }
        viewController?.navigationController?.pushViewController(module.view, animated: true)
    }
}
