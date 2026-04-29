import UIKit

protocol ProjectEditRouterInputProtocol {
    func close()
}

final class ProjectEditRouter: ProjectEditRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
