import UIKit

protocol EditProjectRouterInputProtocol {
    func close()
}

final class EditProjectRouter: EditProjectRouterInputProtocol {
    weak var viewController: UIViewController?

    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
