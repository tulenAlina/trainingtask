import UIKit

protocol EditTaskRouterInputProtocol {
    var onProjectSelect: ((Project) -> Void)? { get set }
    var onEmployeeSelect: ((Employee) -> Void)? { get set }
    func showProjects()
    func showEmployees()
    func close()
}

final class EditTaskRouter: EditTaskRouterInputProtocol {
    weak var viewController: UIViewController?
    
    var onProjectSelect: ((Project) -> Void)? {
        didSet {
            showProjects()
        }
    }
    
    var onEmployeeSelect: ((Employee) -> Void)? {
        didSet {
            showEmployees()
        }
    }
    
    func showProjects() {
        guard let onProjectSelect else { return }
       let projectsViewController = ProjectsViewController(mode: .selection(onSelect: onProjectSelect))
       viewController?.navigationController?.pushViewController(projectsViewController, animated: true)
    }
    
    func showEmployees() {
        guard let onEmployeeSelect else { return }
        let employeesViewController = EmployeesViewController(mode: .selection(onSelect: onEmployeeSelect))
        viewController?.navigationController?.pushViewController(employeesViewController, animated: true)
    }

    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
