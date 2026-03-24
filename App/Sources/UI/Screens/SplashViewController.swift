import UIKit

final class SplashViewController: UIViewController {
    private let nameLabel = UILabel()
    private let versionLabel = UILabel()
    
    private func navigateToMainMenu() {
        guard let window = view.window else {return}
        let mainMenuVC = MainMenuViewController()
        
        let navigation = UINavigationController(rootViewController: mainMenuVC)
        window.rootViewController = navigation
    }
    
    private func loadVersion() -> String? {
        guard let path = Bundle.main.path(forResource: "version", ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {return nil}
        return content
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        nameLabel.text = "TrainingApp"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if let version = loadVersion()?.replacingOccurrences(of: "version=", with: "") {
            versionLabel.text = "Версия \(version)"
        }
        
        view.addSubview(nameLabel)
        view.addSubview(versionLabel)
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.navigateToMainMenu()
        }
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -5),
            
            versionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            versionLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
    }
}
