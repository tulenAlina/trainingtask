import UIKit

protocol EditEmployeeRouterInputProtocol {
    func close()
}

final class EditEmployeeRouter: EditEmployeeRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
