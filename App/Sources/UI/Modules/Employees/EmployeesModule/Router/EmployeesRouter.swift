import UIKit

protocol EmployeesRouterInputProtocol {
    func pushDetailScreen(for employee: Employee, moduleOutput: EmployeeDetailModuleOutputProtocol)
    func pushAddEmployeeScreen(moduleOutput: EditEmployeeModuleOutputProtocol)
    func close()
}

final class EmployeesRouter: EmployeesRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushDetailScreen(for employee: Employee, moduleOutput: EmployeeDetailModuleOutputProtocol) {
        
        let detailModule = EmployeeDetailModule.build(employee: employee, moduleOutput: moduleOutput)
        viewController?.navigationController?.pushViewController(detailModule.view, animated: true)
    }
    
    func pushAddEmployeeScreen(moduleOutput: EditEmployeeModuleOutputProtocol) {
        let editModuleViewController = EditEmployeeModule.build(moduleOutput: moduleOutput)
        editModuleViewController.input.createEmployee()
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
