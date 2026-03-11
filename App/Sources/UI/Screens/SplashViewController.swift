import UIKit

final class SplashViewController: UIViewController {
    let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        nameLabel.text = "TrainingApp"
        nameLabel.textAlignment = .center
        nameLabel.center = view.center
        view.addSubview(nameLabel)
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.navigateToMainMenu()
        }
        
        
    }
    
    private func navigateToMainMenu() {
        guard let window = view.window else {return}
        let mainMenuVC = MainMenuViewController()
        
        window.rootViewController = mainMenuVC
    }
}
