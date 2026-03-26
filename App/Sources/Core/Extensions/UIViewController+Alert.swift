import UIKit

extension UIViewController {
    func showAlert (_ message: String) {
        let alert = UIAlertController(title: Localized.Alert.title.localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localized.Alert.ok.localized, style: .default))
        present(alert, animated: true)
    }
}
