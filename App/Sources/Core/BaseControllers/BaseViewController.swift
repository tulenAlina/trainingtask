import UIKit

class BaseViewController: UIViewController {
    private var navigationRightButton: UIBarButtonItem?
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        view.bringSubviewToFront(loadingIndicator)
    }
    
    func startLoading() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        navigationRightButton?.isEnabled = false
    }
        
    func stopLoading() {
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
        navigationRightButton?.isEnabled = true
    }
    
    func setupNavigationBar(navigationTitle title: String, rightButtonTitle: String? = nil, rightButtonSystemItem: UIBarButtonItem.SystemItem? = nil, rightButtonAction action: Selector? = nil) {
        
        self.title = title
        
        if let rightButtonTitle {
            let button = UIBarButtonItem(title: rightButtonTitle, style: .done, target: self, action: action)
            navigationItem.rightBarButtonItem = button
            navigationRightButton = button
        } else if let rightButtonSystemItem {
            let button = UIBarButtonItem(barButtonSystemItem: rightButtonSystemItem, target: self, action: action)
            navigationItem.rightBarButtonItem = button
            navigationRightButton = button
        }
    }
    
    private func setupUI() {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionEndEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func actionEndEditing() {
        view.endEditing(true)
    }
}
