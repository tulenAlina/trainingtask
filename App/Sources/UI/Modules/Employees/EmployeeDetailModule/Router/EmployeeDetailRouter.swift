import UIKit

protocol EmployeeDetailRouterInputProtocol {
    func openEditScreen(employee: Employee, moduleOutput: EditEmployeeModuleOutputProtocol)
    func close()
}

final class EmployeeDetailRouter: EmployeeDetailRouterInputProtocol {
    weak var viewController: UIViewController?

    func openEditScreen(employee: Employee, moduleOutput: EditEmployeeModuleOutputProtocol) {
        let editModuleViewController = EditEmployeeModule.build(moduleOutput: moduleOutput)
        editModuleViewController.input.updateEmployee(employee: employee)
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
