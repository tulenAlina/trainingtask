import UIKit

protocol TaskEditRouterInputProtocol {
    func pushProjectsModule(output: ProjectSelectionOutputProtocol)
    func pushEmployeesModule(output: EmployeeSelectionOutputProtocol)
    func close()
}

final class TaskEditRouter: TaskEditRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushProjectsModule(output: ProjectSelectionOutputProtocol) {
        let projectsModule = ProjectsModule.build(selectionOutput: output)
        viewController?.navigationController?.pushViewController(projectsModule.view, animated: true)
    }
    
    func pushEmployeesModule(output: EmployeeSelectionOutputProtocol) {
        let employeesModule = EmployeesModule.build(selectionOutput: output)
        viewController?.navigationController?.pushViewController(employeesModule.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
