import UIKit

protocol EmployeesRouterInputProtocol {
    func openDetailScreen(for employee: Employee, moduleOutput: EmployeeDetailModuleOutputProtocol)
    func openAddEmployeeScreen(moduleOutput: EditEmployeeModuleOutputProtocol)
}

final class EmployeesRouter: EmployeesRouterInputProtocol {
    weak var viewController: UIViewController?

    func openDetailScreen(for employee: Employee, moduleOutput: EmployeeDetailModuleOutputProtocol) {
        
        let detailModule = EmployeeDetailModule.build(employee: employee, moduleOutput: moduleOutput)
        viewController?.navigationController?.pushViewController(detailModule.view, animated: true)
    }
    
    func openAddEmployeeScreen(moduleOutput: EditEmployeeModuleOutputProtocol) {
        let editModuleViewController = EditEmployeeModule.build(moduleOutput: moduleOutput)
        editModuleViewController.input.createEmployee()
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
}
