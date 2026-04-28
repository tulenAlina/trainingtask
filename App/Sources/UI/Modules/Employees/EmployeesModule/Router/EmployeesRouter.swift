import UIKit

protocol EmployeesRouterInputProtocol {
    func pushDetailScreen(for employee: Employee, output: EmployeeDetailModuleOutputProtocol)
    func pushAddEmployeeScreen(output: EditEmployeeModuleOutputProtocol)
    func close()
}

final class EmployeesRouter: EmployeesRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushDetailScreen(for employee: Employee, output: EmployeeDetailModuleOutputProtocol) {
        
        let detailModule = EmployeeDetailModule.build(employee: employee, output: output)
        viewController?.navigationController?.pushViewController(detailModule.view, animated: true)
    }
    
    func pushAddEmployeeScreen(output: EditEmployeeModuleOutputProtocol) {
        let editModuleViewController = EditEmployeeModule.build(output: output)
        editModuleViewController.input.createEmployee()
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
