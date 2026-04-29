import UIKit

protocol EmployeesRouterInputProtocol {
    func pushDetailModule(for employee: Employee, output: EmployeeDetailModuleOutputProtocol)
    func pushAddEmployeeModule(output: EmployeeEditModuleOutputProtocol)
    func close()
}

final class EmployeesRouter: EmployeesRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushDetailModule(for employee: Employee, output: EmployeeDetailModuleOutputProtocol) {
        
        let detailModule = EmployeeDetailModule.build(employee: employee, output: output)
        viewController?.navigationController?.pushViewController(detailModule.view, animated: true)
    }
    
    func pushAddEmployeeModule(output: EmployeeEditModuleOutputProtocol) {
        let editModule = EmployeeEditModule.build(output: output)
        editModule.input.createEmployee()
        viewController?.navigationController?.pushViewController(editModule.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
