import UIKit

protocol EditTaskRouterInputProtocol {
    func showProjects(output: ProjectSelectionOutputProtocol)
    func showEmployees(output: EmployeeSelectionOutputProtocol)
    func close()
}

final class EditTaskRouter: EditTaskRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func showProjects(output: ProjectSelectionOutputProtocol) {
        let projectsViewController = ProjectsModule.build().view
        viewController?.navigationController?.pushViewController(projectsViewController, animated: true)
    }
    
    func showEmployees(output: EmployeeSelectionOutputProtocol) {
        let employeesViewController = EmployeesModule.build().view 
        viewController?.navigationController?.pushViewController(employeesViewController, animated: true)
    }

    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
