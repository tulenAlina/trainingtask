import UIKit

protocol EditTaskRouterInputProtocol: AnyObject {
    func navigateToProjectSelection(completion: @escaping (Project) -> Void)
    func navigateToEmployeeSelection(completion: @escaping (Employee) -> Void)
    func close()
}

final class EditTaskRouter: EditTaskRouterInputProtocol {
    weak var viewController: UIViewController?

    private let settings: SettingsManager
    private let server: Server
    
    init(server: Server, settings: SettingsManager) {
        self.server = server
        self.settings = settings
    }
    
    func navigateToProjectSelection(completion: @escaping (Project) -> Void) {
        let projectsViewController = ProjectsViewController(server: server, settings: settings, mode: .selection(onSelect: completion)) 
        viewController?.navigationController?.pushViewController(projectsViewController, animated: true)
    }
    
    func navigateToEmployeeSelection(completion: @escaping (Employee) -> Void) {
        let employeesViewController = EmployeesViewController(server: server, settings: settings, mode: .selection(onSelect: completion))
        viewController?.navigationController?.pushViewController(employeesViewController, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
