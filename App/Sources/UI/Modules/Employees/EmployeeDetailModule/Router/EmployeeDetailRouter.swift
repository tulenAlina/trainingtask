import UIKit

protocol EmployeeDetailRouterInputProtocol {
    func pushEditScreen(employee: Employee, output: EditEmployeeModuleOutputProtocol)
    func close()
}

final class EmployeeDetailRouter: EmployeeDetailRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushEditScreen(employee: Employee, output: EditEmployeeModuleOutputProtocol) {
        let editModuleViewController = EditEmployeeModule.build(output: output)
        editModuleViewController.input.updateEmployee(employee: employee)
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
