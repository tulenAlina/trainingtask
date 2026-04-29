import UIKit

protocol EmployeeDetailRouterInputProtocol {
    func pushEditModule(employee: Employee, output: EditEmployeeModuleOutputProtocol)
    func close()
}

final class EmployeeDetailRouter: EmployeeDetailRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushEditModule(employee: Employee, output: EditEmployeeModuleOutputProtocol) {
        let editModule = EditEmployeeModule.build(output: output)
        editModule.input.updateEmployee(employee: employee)
        viewController?.navigationController?.pushViewController(editModule.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
