import UIKit

extension UIViewController {
    func showAlert (_ message: String) {
        let alert = UIAlertController(title: Localized.alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localized.ok, style: .default))
        present(alert, animated: true)
    }
}
