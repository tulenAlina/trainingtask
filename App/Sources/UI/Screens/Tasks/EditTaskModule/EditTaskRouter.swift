import UIKit

protocol EditTaskRouterProtocol: AnyObject {
    func navigateToProjectSelection(completion: @escaping (Project) -> Void)
    func navigateToEmployeeSelection(completion: @escaping (Employee) -> Void)
    func close()
}

final class EditTaskRouter: EditTaskRouterProtocol {
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
