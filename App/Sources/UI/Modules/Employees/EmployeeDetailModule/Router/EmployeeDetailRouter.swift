import UIKit

protocol EmployeeDetailRouterInputProtocol {
    func pushEditModule(employee: Employee, output: EmployeeEditModuleOutputProtocol)
    func close()
}

final class EmployeeDetailRouter: EmployeeDetailRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushEditModule(employee: Employee, output: EmployeeEditModuleOutputProtocol) {
        let editModule = EmployeeEditModule.build(output: output)
        editModule.input.updateEmployee(employee: employee)
        viewController?.navigationController?.pushViewController(editModule.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
