import UIKit

class BaseViewController: UIViewController {
    var saveButton: UIBarButtonItem?
    
    var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
    }
    
    override func viewDidLayoutSubviews() {
        view.bringSubviewToFront(loadingIndicator)
    }
    
    private func setupBaseUI() {
        view.backgroundColor = .systemBackground
        setupLoadingIndicator()
        setupTapGesture()
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissObjects))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func startLoading() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        saveButton?.isEnabled = false
    }
        
    func stopLoading() {
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
        saveButton?.isEnabled = true
    }
    
    func setupNavigationTitle(_ title: String) {
        self.title = title
    }
    
    func setupRightBarButton(title: String, action: Selector) {
        let button = UIBarButtonItem(title: title, style: .done, target: self, action: action)
        navigationItem.rightBarButtonItem = button
    }
        
    func setupRightBarButton(systemItem: UIBarButtonItem.SystemItem, action: Selector) {
        let button = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: action)
        navigationItem.rightBarButtonItem = button
    }
    
    func addSaveButton(action: Selector) {
        saveButton = UIBarButtonItem(title: Localized.save, style: .done, target: self, action: action)
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func dismissObjects() {
        view.endEditing(true)
    }
}
