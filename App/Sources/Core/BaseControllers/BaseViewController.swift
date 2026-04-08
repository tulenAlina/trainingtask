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
    
    func setupNavigationBar(navigationTitle title: String, rightButtonTitle btnTitle: String? = nil, rightButtonItem btnItem: UIBarButtonItem.SystemItem? = nil, rightButtonAction action: Selector? = nil) {
        
        self.title = title
        
        if let btnTitle {
            let button = UIBarButtonItem(title: btnTitle, style: .done, target: self, action: action)
            navigationItem.rightBarButtonItem = button
        } else if let btnItem {
            let button = UIBarButtonItem(barButtonSystemItem: btnItem, target: self, action: action)
            navigationItem.rightBarButtonItem = button
        }
    }
    
    @objc func dismissObjects() {
        view.endEditing(true)
    }
}
