import UIKit

protocol SettingsRouterInputProtocol {
    func close()
}

final class SettingsRouter: SettingsRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
