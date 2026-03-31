import UIKit

final class SplashViewController: UIViewController {
    private let nameLabel = UILabel()
    private let versionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupLabels()
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -5),
            
            versionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            versionLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    private func setupLabels() {
        nameLabel.text = "TrainingApp"
        if let version = loadVersion()?.replacingOccurrences(of: "version=", with: "") {
            versionLabel.text = "\(Localized.version) \(version)"
        }
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        view.addSubview(versionLabel)
    }
    
    private func loadVersion() -> String? {
        guard let path = Bundle.main.path(forResource: "version", ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {return nil}
        return content
    }
}
