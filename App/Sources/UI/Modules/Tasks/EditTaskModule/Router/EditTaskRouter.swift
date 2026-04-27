import UIKit

protocol EditTaskRouterInputProtocol {
    func pushProjectsScreen(output: ProjectSelectionOutputProtocol)
    func pushEmployeesScreen(output: EmployeeSelectionOutputProtocol)
    func close()
}

final class EditTaskRouter: EditTaskRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushProjectsScreen(output: ProjectSelectionOutputProtocol) {
        let projectsViewController = ProjectsModule.build(selectionOutput: output).view
        viewController?.navigationController?.pushViewController(projectsViewController, animated: true)
    }
    
    func pushEmployeesScreen(output: EmployeeSelectionOutputProtocol) {
        let employeesViewController = EmployeesModule.build(selectionOutput: output).view 
        viewController?.navigationController?.pushViewController(employeesViewController, animated: true)
    }

    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
