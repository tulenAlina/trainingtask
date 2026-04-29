import UIKit

protocol EmployeeEditRouterInputProtocol {
    func close()
}

final class EmployeeEditRouter: EmployeeEditRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
